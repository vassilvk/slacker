require 'slacker'
require 'spec_helper'
require 'time'
require 'odbc'

describe Slacker::QueryResultMatcher do
  def deep_copy(obj)
    Marshal.load(Marshal.dump(obj))
  end

  before(:each) do
    @subject = [{'Field 1' => 12, 'Field_2' => nil, 'b' => ''},
      {'Field 1' => 'test string', 'Field_2' => ODBC::TimeStamp.new('2011-01-30'), 'b' => 8.9}]
  end

  shared_examples_for 'table-based matcher' do
    it 'correctly rejects a non-matching query result based on wrong columns' do
      one_column_too_few = deep_copy(@subject).each{|row| row.delete('b')}
      one_column_too_many = deep_copy(@subject).each{|row| row['new column'] = 'val 1'}
      wrong_column_name = deep_copy(@subject).each{|row| row.delete('Field_2'); row['Field_x'] = 'val x'}

      @matcher.matches?(one_column_too_few).should be false
      @matcher.failure_message.should == 'Expected 3 field(s), got 2'

      @matcher.matches?(one_column_too_many).should be false
      @matcher.failure_message.should == 'Expected 3 field(s), got 4'

      @matcher.matches?(wrong_column_name).should be false
      @matcher.failure_message.should == 'Expected field "Field_2", got field "b"'
    end

    it 'correctly rejects a non-matching query result based on number of records' do
      one_row_too_few = deep_copy(@subject)
      one_row_too_few.shift
      one_row_too_many = deep_copy(@subject) << @subject[0]
      empty_query_result = []

      @matcher.matches?(one_row_too_few).should be false
      @matcher.failure_message.should == 'Expected 2 record(s), got 1'

      @matcher.matches?(one_row_too_many).should be false
      @matcher.failure_message.should == 'Expected 2 record(s), got 3'

      @matcher.matches?(empty_query_result).should be false
      @matcher.failure_message.should == 'Expected 2 record(s), got 0'
    end

    it 'correctly rejects a non-matching query result based on a value' do
      wrong_int = deep_copy(@subject)
      wrong_int[0]['Field 1'] = 14

      wrong_int_type = deep_copy(@subject)
      wrong_int_type[1]['Field 1'] = 14

      wrong_nil = deep_copy(@subject)
      wrong_nil[0]['Field 1'] = nil

      wrong_non_nil = deep_copy(@subject)
      wrong_non_nil[0]['Field_2'] = 'whatever'
      
      misplaced_fields = deep_copy(@subject)
      misplaced_fields[0].delete('Field 1')
      misplaced_fields[1].delete('Field 1')
      misplaced_fields[0]['Field 1'] = 12
      misplaced_fields[1]['Field 1'] = 'test string'

      @matcher.matches?(wrong_int).should be false
      @matcher.failure_message.should == 'Field "Field 1", Record 1: Expected value "12", got "14"'


      @matcher.matches?(wrong_int_type).should be false
      @matcher.failure_message.should == 'Field "Field 1", Record 2: Expected value "test string", got "14"'

      @matcher.matches?(wrong_nil).should be false
      @matcher.failure_message.should == 'Field "Field 1", Record 1: Expected value "12", got <NULL>'

      @matcher.matches?(wrong_non_nil).should be false
      @matcher.failure_message.should == 'Field "Field_2", Record 1: Expected value <NULL>, got "whatever"'

      @matcher.matches?(misplaced_fields).should be false
      @matcher.failure_message.should == 'Expected field "Field 1", got field "Field_2"'
    end

    it 'correctly compares with a query result' do
      @matcher.matches?(@subject).should be true
    end

    it 'only accepts well formed query result subjects' do
      expected_message = /Can perform query matches only against a well formed query result subject/
      @matcher.matches?(1).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?('test string').should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?(1.1).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?(Time.now).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?(nil).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?([{:f1 => 'x', :f2 => 'y'}, {:f1 => 'x'}]).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?([{:f1 => 'x', :f2 => 'y'}, {:f1 => 'x', :f3 => 'y'}]).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?([{:f1 => 'x', :f2 => 'y'}, {:f1 => 'x', :f2 => 'y', :f3 => 'z'}]).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?([{:f1 => 'x', :f2 => 'y'}, 12]).should be false
      @matcher.failure_message.should =~ expected_message

      @matcher.matches?([12, {:f1 => 'x', :f2 => 'y'}]).should be false
      @matcher.failure_message.should =~ expected_message

      # An array with a single empty row is not a well-formed query result
      @matcher.matches?([{}]).should be false
      @matcher.failure_message.should =~ expected_message
    end
    
  end

  describe 'CSV-based golden master' do
    before(:each) do
      @matcher = Slacker::QueryResultMatcher.new(SpecHelper.load_csv('matcher/test_1.csv'))
    end
    
    it_behaves_like 'table-based matcher'

    it 'correctly compares an empty subject with an empty CSV file' do
      matcher = Slacker::QueryResultMatcher.new(SpecHelper.load_csv('matcher/no_rows.csv'))
      matcher.matches?([]).should be true

      matcher = Slacker::QueryResultMatcher.new(SpecHelper.load_csv('matcher/completely_blank.csv'))
      matcher.matches?([]).should be true
    end
  end

  describe 'Array-based golden master' do
    before(:each) do
      @matcher = Slacker::QueryResultMatcher.new(deep_copy(@subject))
    end

    it_behaves_like 'table-based matcher'

    it 'only accepts well formed query result golden master' do
      expected_message = /Cannot match against a non-well formed golden master array/

      matcher = Slacker::QueryResultMatcher.new([{:f1 => 'x', :f2 => 'y'}, {:f1 => 'x'}])
      matcher.matches?([]).should be false
      matcher.failure_message.should =~ expected_message

      matcher = Slacker::QueryResultMatcher.new([{:f1 => 'x', :f2 => 'y'}, {:f1 => 'x', :f3 => 'y'}])
      matcher.matches?([]).should be false
      matcher.failure_message.should =~ expected_message

      matcher = Slacker::QueryResultMatcher.new([{:f1 => 'x', :f2 => 'y'}, {:f1 => 'x', :f2 => 'y', :f3 => 'z'}])
      matcher.matches?([]).should be false
      matcher.failure_message.should =~ expected_message

      matcher = Slacker::QueryResultMatcher.new([{:f1 => 'x', :f2 => 'y'}, 12])
      matcher.matches?([]).should be false
      matcher.failure_message.should =~ expected_message

      matcher = Slacker::QueryResultMatcher.new([12, {:f1 => 'x', :f2 => 'y'}])
      matcher.matches?([]).should be false
      matcher.failure_message.should =~ expected_message
    end

    it 'correctly compares an empty subject with an empty golden master' do
      matcher = Slacker::QueryResultMatcher.new([])
      matcher.matches?([]).should be true
    end
  end

  shared_examples_for 'single-value-based matcher' do
    it 'should correctly match the first value in the result set' do
      matcher = Slacker::QueryResultMatcher.new(@correct_golden_master)
      matcher.matches?(@subject).should be true
    end

    it 'should correctly reject a non-matching first item by value' do
      if !@wrong_value_golden_master.nil? #Skip nil from value check when the master is nil
        matcher = Slacker::QueryResultMatcher.new(@wrong_value_golden_master)
        matcher.matches?(@subject).should be false
        matcher.failure_message.should =~ /Expected value "#{@wrong_value_golden_master}", got "#{@subject[0].values[0]}"/
      end
    end

    it 'should correctly reject a non-matching first item by type' do
      matcher = Slacker::QueryResultMatcher.new(@wrong_type_golden_master)
      matcher.matches?(@subject).should be false
      matcher.failure_message.should =~ /Expected type "#{@wrong_type_golden_master.class}", got \"#{@subject[0].values[0].class}\"/
    end
  end

  describe 'Integer-based golden master' do
    before(:each) do
      @subject = [{'Field 1' => 14, 'Field_2' => 'whatever'}]
      @correct_golden_master = 14
      @wrong_value_golden_master = 15
      @wrong_type_golden_master = 'whatever'
    end

    it_behaves_like 'single-value-based matcher'
  end

  describe 'String-based golden master' do
    before(:each) do
      @subject = [{'Field 1' => 'test string', 'Field_2' => 12}]
      @correct_golden_master = 'test string'
      @wrong_value_golden_master = 'whatever'
      @wrong_type_golden_master = 15
    end

    it_behaves_like 'single-value-based matcher'
  end

  describe 'Floating point-based golden master' do
    before(:each) do
      @subject = [{'Field 1' => 18.2, 'Field_2' => 12}]
      @correct_golden_master = 18.2
      @wrong_value_golden_master = 18.7
      @wrong_type_golden_master = 15
    end

    it_behaves_like 'single-value-based matcher'
  end

  describe 'BigDecimal point-based golden master' do
    before(:each) do
      @subject = [{'Field 1' => -3.12e-5, 'Field_2' => 12}]
      @correct_golden_master = -0.0000312
      @wrong_value_golden_master = -0.0000317
      @wrong_type_golden_master = 15
    end

    it_behaves_like 'single-value-based matcher'
  end

  describe 'Date-based golden master' do
    before(:each) do
      @subject = [{'Field 1' => Time.parse('1/1/2011'), 'Field_2' => 12}]
      @correct_golden_master = Time.parse('1/1/2011')
      @wrong_value_golden_master = Time.parse('2/1/2011')
      @wrong_type_golden_master = 'whatever'
    end

    it_behaves_like 'single-value-based matcher'
  end

  describe 'DateTime2-based golden master' do
    before(:each) do
      @subject = [{'Field 1' => Time.parse('2017-01-01.000000'), 'Field_2' => 12}]
      @correct_golden_master = Time.parse('2017-01-01 00:00:00')
      @wrong_value_golden_master = Time.parse('2017-02-01.000000')
      @wrong_type_golden_master = 'whatever'
    end

    it_behaves_like 'single-value-based matcher'
  end

  

  describe 'Nil-based golden master' do
    before(:each) do
      @subject = [{'Field 1' => nil, 'Field_2' => 12}]
      @correct_golden_master = nil
      @wrong_value_golden_master = nil # There is no wrong value for nil-based master
      @wrong_type_golden_master = 'whatever'
    end

    it_behaves_like 'single-value-based matcher'
  end

  it 'correctly matches a multi-result subject' do
    subject = [@subject, [{:Field_x => 12}]]
    matcher = Slacker::QueryResultMatcher.new(deep_copy(@subject))
    matcher.matches?(subject).should be true
  end

  it 'correctly rejects a wrong multi-result subject' do
    subject = [[{:Field_x => 12}], @subject]
    matcher = Slacker::QueryResultMatcher.new(deep_copy(@subject))
    matcher.matches?(subject).should be false
    matcher.failure_message.should == 'Expected 3 field(s), got 1'
  end
end
