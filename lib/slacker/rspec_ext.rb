require 'slacker'
require 'slacker/query_result_matcher'
require 'csv'

module Slacker
  module RSpecExt
    def query(query_string, options = {}, log_name = nil)
      log_name ||= Slacker.construct_log_name('query', query_string, options)
      sql = Slacker.sql_from_query_string(query_string, options)
      @results = Slacker.query_script(example, sql, log_name)
      if block_given?
        yield
      end
      @results
    end

    def result(index = 1, options = {})
      # Flatten the result in case we're getting a multi-result-set response
      res = case !@results.empty? && @results[0].kind_of?(Array)
      when true
        raise "The query result contains only #{@results.count} result set(s)" unless @results.count >= index
        @results[index - 1]
      else
        raise "The query result contains a single result set" unless index == 1
        @results
      end

      #Optionally extract the record and or the field
      if options[:record] != nil
        raise "The result set contains only #{res.count} record(s)" unless res.count >= options[:record]
        res = res[options[:record] - 1]
        if options[:field] != nil
          raise "The result set does not contain field \"#{options[:field]}\"" unless res[options[:field]] != nil
          res = res[options[:field]]
        end
      end

      res
    end

    # Get a matcher which will compare the query results to a golden master
    def match(golden_master)
      QueryResultMatcher.new(Slacker.filter_golden_master(golden_master))
    end

    def load_csv(csv_file_or_object, table_name, log_name = nil)
      log_name ||= "load_csv '#{csv_file_or_object.kind_of?(CSV::Table) ? 'CSV Object' : csv_file_or_object }', 'table_name'"
      csv_object = case csv_file_or_object
      when String then Slacker.get_csv(csv_file_or_object)
      when CSV::Table then csv_file_or_object
      when Array then Slacker.hash_array_to_csv(csv_file_or_object)
      end

      Slacker.load_csv(example, csv_object, table_name, log_name)
    end

    def csv(csv_file)
      Slacker.get_csv(csv_file)
    end

    def sql
      Slacker.sql(self)
    end

    def yes?(val)
      val != nil && val.downcase == 'yes'
    end
  end
end
