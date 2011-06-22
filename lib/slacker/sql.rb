require 'slacker'
require 'slacker/rspec_ext'

module Slacker
  class Sql < BasicObject
    attr_accessor :base_folder, :rspec_ext

    def initialize(base_folder, rspec_ext)
      @base_folder = base_folder
      @rspec_ext = rspec_ext
    end

    def method_missing(method_name, *params, &block)
      ::Kernel.raise "Slacker::Sql.rspec_ext not initialized" if rspec_ext.nil?
      ::Kernel.raise "Missing folder #{base_folder}" if !::File.directory?(base_folder)

      method_name = method_name.to_s
      
      if ::File.directory?(::File.join(base_folder, method_name))
        ::Slacker::Sql.new(::File.join(base_folder, method_name), rspec_ext)
      else
        sql_file = ::Slacker.sql_file_from_method_name(base_folder, method_name)
        case sql_file
        when nil
          ::Kernel.raise "No SQL file found corresponding to method '#{method_name}' in folder #{base_folder}"
        else
          rspec_ext.query sql_file, *params, &block
        end
      end
    end

    def respond_to?(method_name)
      method_name = method_name.to_s
      ::Kernel.raise "Slacker::Sql.rspec_ext not initialized" if rspec_ext.nil?
      ::File.directory?(::File.join(base_folder, method_name)) ||
        !(::Slacker.sql_file_from_method_name(base_folder, method_name).nil?)
    end
  end
end
