module Slacker
  module SqlPreprocessor
    IVAR_REX = /%{\s*(.*?)\s*}/

    def self.executable_sql(sql, example)
      # Replace all appearances of %{} with the values of the corresponding example instance variables
      sql.gsub(IVAR_REX) do
        ivar = $1.to_sym
        instance = example.example_group_instance

        if instance.instance_variable_defined?(ivar)
          instance.instance_variable_get(ivar).to_s
        else
          raise "Example is missing instance variable #{ivar}"
        end
      end
    end

    def self.debuggable_sql(sql)
      # Replace all appearances of %{} with the names of the sql variables
      sql.gsub(IVAR_REX) {$1}
    end
  end
end