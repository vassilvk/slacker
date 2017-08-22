# This specification explores the use of helper methods sproc, s_func and t_func
# used for testing stored procedures, scalar functions and table-valued functions
# without the need to create sql template files.
# The helper methods are implemented in file lib/helpers/common_helper.rb and are
# automatically included and available in every Slacker specification file.
#
# If you're looking for examples of using the template-files technique
# see examples in spec/template_examples.rb.

describe 'My database' do
  
  # Create the sample tables before each example.
  # All updates will be discarded at the end of each example,
  # including the ones introduced in the 'before :each' section below.
  before :each do
    sql.helper_method_examples.create_tables
  end

  
  # An example of using helper method sproc.
  it 'is hosted on a SQL Server instance' do
    # Call sp_server_info using helper method sproc.
    result = sproc('sp_server_info')

    # sp_server_info returns a single resultset with server attributes.
    expect(result.count).to be > 1

    # Convert the returned resultset to a hash of server attributes.
    server_attributes = result.map{|r| [r[:attribute_name], r[:attribute_value]]}.to_h

    expect(server_attributes['DBMS_NAME']).to be == 'Microsoft SQL Server'
  
  end

  
  # Another sproc example - calling a multi-resultset stored procedures with parameters.
  it 'contains table dbo.OrderItem' do

    # Invoke sp_help for dbo.OrderItem.
    result = sproc('sp_help', :objname => 'dbo.OrderItem')

    expect(result.count).to be == 7
    
    # Verify the name of the table returned in the first resultset.
    expect(result[0][0][:Name]).to be == 'OrderItem'

    # Inspect a few columns returned in the second resultset.
    expect(result[1][0][:Column_name]).to be == 'order_id'
    expect(result[1][1][:Column_name]).to be == 'customer_id'

    # Verify that order_id is the identity of the table - returned in the third resultset.
    expect(result[2][0][:Identity]).to be == 'order_id'
  
  end

  
  # An example of using sproc with output parameters.
  it 'can be used to perform formatting operations' do
    
    # You can call a stored procedure which expects output parameters
    # by passing the output parameters in a second hash, which provides
    # the name of the variable to pass into the output parameter and
    # the type of that variable.
    # The result of calling a stored procedure will include a resultset with
    # the value of all output parameters selected as columns.
    
    result = sproc('xp_sprintf',
      # Input parameters.
      {
        :format => 'Hello %s',
        :argument1 => 'Marry'
      },
      # Output parameters.
      {
        :string => 'varchar(100)'
      })[0][:string]

    expect(result).to be == 'Hello Marry'

  end

  
  # An example of using sproc with named output parameters.
  it 'can be used to perform formatting operations (take 2)' do
    
    # This example is the same as the above, but this time
    # the output variable name is different from the name
    # of the output parameter.
    # To accomplish this, instead of passing a {:param_name => 'type'} hash
    # we are passing {:param_name => {:var_name => 'type'}} hash.

    result = sproc('xp_sprintf',
      # Input parameters.
      {
        :format => 'Hello %s',
        :argument1 => 'John'
      },
      # Output parameters.
      {
        :string => {:my_output_var => 'varchar(100)'}
      })[0][:my_output_var]

    expect(result).to be == 'Hello John'

  end

  
  # An example of using helper method s_func to call a scalar function.
  it 'exposes system scalar function COALESCE' do
    result = s_func('COALESCE', nil, 12, nil, 24)
    expect(result).to be == 12
  end

  # An example of using t_func.
  it 'exposes a dbo.tf_Fibonacci UDF table-valued function' do
    # Create a Fibonacci sequence generator table-valued function.
    # This is done here for demonstration purposes only.
    # Typically you would not be creating your target logic as part of the test.
    sql.helper_method_examples.create_tf_fibonacci

    # Test the Fibonacci sequence function by invoking it with a variety of parameters
    # and matching the results with expected data points stored in CSV files.

    expect(t_func('dbo.tf_Fibonacci', 1000000)).to match('helper_method_examples/fibonacci_1.csv')

    expect(t_func('dbo.tf_Fibonacci', 3000000)).to match('helper_method_examples/fibonacci_2.csv')

    expect(t_func('dbo.tf_Fibonacci', 999999999)).to match('helper_method_examples/fibonacci_3.csv')
  
  end

end