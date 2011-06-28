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
        yield @results
      end
      @results
    end

    def sql
      Slacker.sql(self)
    end

    # Get a matcher which will compare the query results to a golden master
    def match(golden_master)
      QueryResultMatcher.new(Slacker.filter_golden_master(golden_master))
    end

    def csv(csv_file)
      Slacker.get_csv(csv_file)
    end

    def touch_csv(csv_file_or_object, fields, field_generators = {})
      Slacker.touch_csv(csv_file_or_object, fields, field_generators)
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

    def yes?(val)
      val != nil && val.downcase == 'yes'
    end
  end
end
