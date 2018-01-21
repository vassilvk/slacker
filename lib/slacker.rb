require 'bundler/setup'
require "slacker/version"
require 'slacker/application'
require 'slacker/configuration'
require 'slacker/sql'
require 'slacker/formatter'
require 'slacker/sql_preprocessor'
require 'csv'
require 'erb'

module Slacker
  class << self
    def application
      @application ||= Slacker::Application.new(configuration)
    end

    def sql(rspec_ext)
      Slacker::Sql.new(configuration.expand_path('sql'), rspec_ext)
    end

    def configuration
      @configuration ||= Slacker::Configuration.new
    end

    def configure
      yield configuration
    end

    def sql_template_path_stack
      if @sql_template_path_stack.nil?
        @sql_template_path_stack = []
        @sql_template_path_stack.push(configuration.expand_path('sql'))
      end
      @sql_template_path_stack
    end

    # Given a template name produce the path to that template
    def get_sql_template_path(template_name)
      template_base_dir = template_name[0].chr == '/' ? sql_template_path_stack.first : sql_template_path_stack.last
      File.expand_path(template_base_dir + '/' + template_name)
    end

    # Render a template file and return the result
    def render(template_name, options = {})
      template_file_path = get_sql_template_path(template_name)

      if !File.exists?(template_file_path)
        raise "File #{template_file_path} does not exist"
      end

      begin
        sql_template_path_stack.push(File.dirname(template_file_path))
        result = render_text(IO.read(template_file_path, {:mode => 'r:BOM|UTF-8'}), options)
      rescue => detail
        # Report errors in the template
        if detail.backtrace[0] =~ /^\(erb\)/
          raise "Template error in #{template_name}:\n#{detail.backtrace[0]} : #{detail.message}\n"
        else
          raise detail
        end
      ensure
        sql_template_path_stack.pop
      end

      result
    end

    # Render a template test and return the result
    def render_text(template_text, options)
      ERB.new(template_text, 0, '%<>').result(binding)
    end

    def filter_golden_master(golden_master)
      golden_master = case golden_master
      when String
        golden_master =~ /\.csv$/ ? get_csv(golden_master) : golden_master
      else
        golden_master
      end
    end

    def sql_from_query_string(query_string, options = {})
      case query_string
      when /\.sql$/i,/\.erb$/i
        #Pass the file through an ERb template engine
        render(query_string, options)
      else
        query_string
      end
    end

    def get_csv(csv_file_path)
      CSV.read(configuration.expand_path("data/#{csv_file_path}"), {
          :headers => true,
          :encoding => 'UTF-8',
          :header_converters => lambda { |h| h.to_sym unless h.nil? }
      })

    end

    def hash_array_to_csv(raw_array)
      csv_array = []
      raw_array.each do |raw_row|
        csv_array << CSV::Row.new(raw_row.keys, raw_row.values)
      end
      CSV::Table.new(csv_array)
    end

    def sql_file_from_method_name(base_folder, method_name)
      file_name = File.join(base_folder, method_name)

      file_name = case
      when File.exists?("#{file_name}.sql") then "#{file_name}.sql"
      when File.exists?("#{file_name}.sql.erb") then "#{file_name}.sql.erb"
      else nil
      end

      file_name.nil? ? nil : file_name.gsub(/#{Regexp.escape(configuration.expand_path('sql'))}/i, '')
    end

    def construct_log_name(entry_point, query_string, options)
      "#{entry_point} '#{query_string}'" + (options.empty? ? '': ", options = #{options.inspect}")
    end

    # Run a SQL query against an example
    def query_script(example, sql, log_name=nil)
      log_name ||= 'Run SQL Script'

      debuggable_sql = SqlPreprocessor.debuggable_sql(sql)
      executable_sql = SqlPreprocessor.executable_sql(sql, example)

      example.metadata[:sql] += ((example.metadata[:sql] == '' ? '' : "\n\n") + "-- #{log_name.split(/\r\n|\n/).join("\n-- ")}\n#{debuggable_sql}")
      application.query_script(executable_sql)
    end

    def load_csv(example, csv, table_name, log_name = nil)
      csv_a = csv.to_a
      sql = nil
      csv_a.each_with_index do |row, index|
        if index == 0
          sql = "INSERT INTO #{table_name}(#{row.map{|header| "[#{header}]"}.join(',')})"
        else
          sql += ("\nSELECT #{row.map{|val| val.nil? ? 'NULL': "'#{val}'"}.join(',')}" + (index < (csv_a.count - 1) ? ' UNION ALL' : ''))
        end
      end
      query_script(example, sql, log_name) unless sql.nil?
    end

    def touch_csv(csv_file_or_object, fields, field_generators = {})
      csv_obj = csv_file_or_object.kind_of?(String) ? get_csv(csv_file_or_object) : csv_file_or_object
      fields = fields.is_a?(Array) ? fields : [fields]

      # Adjust the csv if we are providing more records than there are in the csv
      csv_row_count = csv_obj.to_a.count - 1

      (fields.count - csv_row_count).times do |index|
        csv_obj << csv_obj[index % csv_row_count].fields
      end

      # Add the field generators to the hard-coded fields
      field_generators.each do |key, value|
        fields.each_with_index do |record, index|
          record[key] = value.to_s + index.to_s
        end
      end

      fields.each_with_index do |record, index|
        record.each do |key, value|
          csv_obj[index][key.to_sym.downcase] = value
        end
      end
      csv_obj
    end
    
    def mixin_module(module_class)
      extend module_class
    end
    
  end
end
