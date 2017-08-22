# A helper module with methods which streamline execution of various
# programmable objects without the need to craft custom slacker *.sql templates.

module CommonHelper
  # Construct a select statement with optional variable declaration.
  # Inject a select statement at the end which selects all variables
  def select_vars(vars, sql_script, options = {:declare_vars => true}, &block)
    sql.common.select_vars({:vars => vars, :sql_script => sql_script, :options => options}, &block)
  end
  
  # Invoke a scalar function by name and with an arbitrary list of parameters.
  def s_func(func_name, *params)
    raise 's_func called with a block' if block_given?

    # Extract the optional options at the end of the params array.
    options = options_from_params(params)

    sql_value_params = params.map{|param| sql_value(param) }
    
    if options[:date_to_iso8601]
      query("select CONVERT(NVARCHAR(MAX),#{func_name}(#{sql_value_params.join(', ')}), 101) as value;")[0][:value]
    else
      query("select #{func_name}(#{sql_value_params.join(', ')}) as value;")[0][:value]
    end
  end

  # Invoke a table valued function with an arbitrary list of parameters.
  # Yield results to the optionally passed in lambda block.
  def t_func(func_name, *params, &block)
    # Extract the optional options at the end of the params array.
    options = options_from_params(params)
    
    order_by_clause = options[:order_by] != nil ? " order by #{options[:order_by]}" : ""

    if params.any? {|p| p.class == TableVariable}
      sql.common.t_func :func_name => func_name, :params => params, :order_by_clause => order_by_clause, &block
    else
      sql_value_params = params.map{|param| sql_value(param) }
      query "select * from #{func_name}(#{sql_value_params.join(', ')})#{order_by_clause};", &block
    end
  end

  # Invoke a stored procedure with an arbitrary list of input and output
  # parameters passed in as hashes to allow named parameters.
  def sproc(sproc_name, params = {}, out_params = {}, &block)
    if out_params.count > 0 || params.any? {|p| p[1].class == TableVariable}
      sql.common.sproc :sproc_name => sproc_name, :params => params, :out_params => out_params, &block
    else
      # Bypass the call to the template if no TableVariable parameter is present.
      # This speeds up execution of a simple sproc calls up to x2.
      query "exec #{sproc_name}\n#{sproc_params(params, {})};", &block
    end
  end
  
  # Convert parameter values to their SQL string representation.
  def sql_value(p)
    if p
      case p
      when String then
        # Do not put the %{ } escapes into quotes - this will be replaced by the Slacker's SQL preprocessor.
        # Updated to also ignore hex strings for sql varbinary values, and pre-quoted values.
        (p =~ /^(%{.*?}|0x[0-9a-fA-F]*|'.*')$/) != nil ? p :  "'#{p}'"
      when TableVariable
        p.name
      else p.to_s
      end
    else
      'NULL'
    end
  end

  # Extract the last parameter if of type hash, otherwise return an empty hash.
  def options_from_params(params)
    options = {}
    pcount = params.count
    if pcount > 0 && params[pcount - 1].is_a?(Hash)
      options = params[pcount - 1]
      params.delete_at(pcount - 1)
    end

    options
  end

  # Generate a stored procedure parameter list.
  def sproc_params(in_params, out_params)
    expanded = []
    
    out_params.each do |key, value|
      expanded.push "@#{key.to_s} = @#{value} out"
    end
    
    in_params.each do |key, value|
      expanded.push "@#{key.to_s} = #{sql_value(value)}"
    end
    
    expanded.count == 0 ? '' : '  ' + expanded.join(",\n  ")
  end

end

# Use this class to pass in table-valued parameters when calling sproc, t_func and s_func. 
class TableVariable
  @name = ''
  @type = ''
  @fields = []
  @values = []
  @usage = 0
    
  def initialize(name, type, fields, values)
    @name = name.start_with?('@') ? name : '@' + name
    @type = type
    @fields = fields
    @values = values
    @usage = 0
  end
    
  attr_reader :type
  attr_reader :fields
  attr_reader :values
    
  def name
    @name + "_" + @usage.to_s
  end
    
  def increment
    @usage += 1
  end
end 
