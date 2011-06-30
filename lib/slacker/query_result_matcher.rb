require 'csv'

module Slacker
  DATE_FORMAT = "%m/%d/%Y"

  class QueryResultMatcher
    def initialize(golden_master)
      @golden_master = golden_master
      @failure_message = ''
    end

    def matches?(subject)
      does_match = false

      subject = normalize_query_result_subject(subject)

      catch :no_match do
        test_type_match(subject)
        test_value_match(subject)
        does_match = true
      end
      
      does_match
    end

    def failure_message_for_should
      @failure_message
    end

    private

    #test if the subject type is consistent with the golden master
    def test_type_match(subject)
      if !is_well_formed_query_result?(subject)
        throw_no_match "Can perform query matches only against a well formed query result subject"
      end
      
      if (@golden_master.kind_of? Array) && !is_well_formed_query_result?(@golden_master)
        throw_no_match "Cannot match against a non-well formed golden master array"
      end
    end

    def test_value_match(subject)
      case @golden_master
      when CSV::Table
        test_csv_table_match(subject)
      when Array
        test_array_match(subject)
      else
        test_single_value_match(subject)
      end
    end

    # Compare the golden master CSV table with the subject query result
    def test_csv_table_match(subject)
      # Compare the fields
      if !subject.empty?
        subject_fields = subject[0].keys
        master_fields = @golden_master.headers

        if subject_fields.count != master_fields.count
          throw_no_match "Expected #{master_fields.count} field(s), got #{subject_fields.count}"
        end

        master_fields.each_with_index do |column, index|
          if column != subject_fields[index]
            throw_no_match "Expected field \"#{column}\", got field \"#{subject_fields[index]}\""
          end
        end
      end

      # Compare the number of records
      subject_record_count = subject.count
      master_record_count = @golden_master.inject(0){|count| count += 1}
      if subject_record_count != master_record_count
        throw_no_match "Expected #{master_record_count} record(s), got #{subject_record_count}"
      end

      # Compare the values of the golden master with the subject
      current_row = 0
      @golden_master.each do |row|
        row.each do |field, master_string|
          subject_value = subject[current_row][field]
          if !match_values?(master_string, subject_value)
            throw_no_match "Field \"#{field}\", Record #{current_row + 1}: Expected value #{master_string.nil? ? '<NULL>' : "\"#{master_string}\""}, got #{subject_value.nil? ? '<NULL>' : "\"#{subject_value}\""}"
          end
        end
        current_row += 1
      end
    end

    def match_types?(master_val, subject_val)
      subject_val.kind_of? master_val.class
    end

    def match_values?(master_val, subject_val)
      if master_val.nil?
        master_val == subject_val
      elsif master_val.kind_of?(String)
        case subject_val
        when ODBC::TimeStamp
          (!!Time.strptime(master_val, DATE_FORMAT) rescue false) && Time.strptime(master_val, DATE_FORMAT) == ODBC::to_time(subject_val)
        when Float
          (!!Float(master_val) rescue false) && Float(master_val) == subject_val
        else
          subject_val.to_s == master_val.to_s
        end
      else
        subject_val.to_s == master_val.to_s
      end
    end

    def test_array_match(subject)
      # Compare the fields
      if !(subject.empty? || @golden_master.empty?)
        subject_fields = subject[0].keys
        master_fields = @golden_master[0].keys

        if subject_fields.count != master_fields.count
          throw_no_match "Expected #{master_fields.count} field(s), got #{subject_fields.count}"
        end

        master_fields.each_with_index do |column, index|
          if column != subject_fields[index]
            throw_no_match "Expected field \"#{column}\", got field \"#{subject_fields[index]}\""
          end
        end
      end

      # Compare the number of records
      subject_record_count = subject.count
      master_record_count = @golden_master.count
      if subject_record_count != master_record_count
        throw_no_match "Expected #{master_record_count} record(s), got #{subject_record_count}"
      end

      # Compare the values of the golden master with the subject
      current_row = 0
      @golden_master.each do |row|
        row.each do |field, master_value|
          subject_value = subject[current_row][field]
          if !match_values?(master_value, subject_value)
            throw_no_match "Field \"#{field}\", Record #{current_row + 1}: Expected value #{master_value.nil? ? '<NULL>' : "\"#{master_value}\""}, got #{subject_value.nil? ? '<NULL>' : "\"#{subject_value}\""}"
          end
        end
        current_row += 1
      end
    end

    def is_well_formed_query_result?(arr)
      return false unless arr.kind_of? Array
      header =[]
      arr.find{|row| !row.kind_of?(Hash) || (header = header.empty? ? row.keys : header) != row.keys || row.keys.empty?}.nil?
    end

    def test_single_value_match(subject)
      subject_value = subject[0].values[0]
      subject_field = subject[0].keys[0]
      if !match_types?(@golden_master, subject_value)
        throw_no_match "Field \"#{subject_field}\", Record 1: Expected type \"#{@golden_master.class}\", got \"#{subject_value.class}\""
      end

      if !match_values?(@golden_master, subject_value)
        throw_no_match "Field \"#{subject_field}\", Record 1: Expected value #{@golden_master.nil? ? '<NULL>' : "\"#{@golden_master}\""}, got #{subject_value.nil? ? '<NULL>' : "\"#{subject_value}\""}"
      end
    end

    # In case of a multi-resultset subject, extract the first result set
    def normalize_query_result_subject(subject)
      subject.kind_of?(Array) && !subject.empty? && is_well_formed_query_result?(subject[0]) ? subject[0] : subject
    end

    def throw_no_match(message)
      @failure_message = message
      throw :no_match
    end
  end
end
