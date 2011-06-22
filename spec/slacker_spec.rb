require 'slacker'
require 'spec_helper'

describe Slacker do
  it 'exposes a singleton application object' do
    app = Slacker::application
    app.should equal(Slacker::application)
  end

  it 'and it''s base folder can be configured through a call to configure' do
    Slacker.configure do |config|
      config.base_dir = 'xyz'
    end

    Slacker.configuration.base_dir.should == 'xyz'
  end

  it 'converts a hash array to csv' do
    csv = Slacker.hash_array_to_csv [{'a' => 1, 'b' => 2}, {'a' => 3, 'b' => 4}]
    csv.to_csv.should == "a,b\n1,2\n3,4\n"
  end

  context 'provides SQL resolution' do
    before(:each) do
      Slacker.configure do |config|
        config.base_dir = SpecHelper.expand_test_files_path('test_slacker_project')
      end
    end

    specify 'which resolves to a SQL string when a non-file is sent to it' do
      Slacker.sql_from_query_string("select 'abc' as xyz").should == "select 'abc' as xyz"
    end

    specify 'which resolves to the correct contents of a SQL file' do
      Slacker.sql_from_query_string("test_1.sql").should == "select 1;"
    end

    context 'of an ERB file' do
      specify 'with no params' do
        Slacker.sql_from_query_string("no_params.sql.erb").should == "select 1;\nselect 2;\n"
      end

      specify 'with params' do
        Slacker.sql_from_query_string("params.sql.erb", {:param1 => 11, :param2 => 12}).should == "select 11;\nselect 12;"
      end

      specify 'which calls another ERB file with no params' do
        Slacker.sql_from_query_string("nested.sql.erb").should == "select 1;\nselect 2;\n"
      end

      specify 'which calls another ERB file with params' do
        Slacker.sql_from_query_string("nested_with_params.sql.erb", {:param1 => 21, :param2 => 22}).should == "select 21;\nselect 22;"
      end

      specify 'which calls complex multi-nested file' do
        Slacker.sql_from_query_string("multi_nested.sql.erb", {:seed => 1}).should == "seed 1;\nselect 3;\nselect 4;"
      end
    end
  end
end