module Slacker
  class Configuration
    attr_accessor :base_dir, :error_stream, :output_stream, :formatter, :db_server, :db_name, :db_user, :db_password, :console_enabled

    def initialize
      @console_enabled = true
      @base_dir = Dir.pwd
      @error_stream = nil
      @output_stream = nil
      @rspec_args = nil
      @formatter = nil
      @db_server = nil
      @db_name = nil
      @db_user = nil
      @db_password = nil
    end

    def expand_path(path)
      File.expand_path("#{@base_dir}/#{path}")
    end

    def console_enabled
      @console_enabled
    end

    def console_enabled=(value)
      @console_enabled = value
      if @console_enabled
        @error_stream = $stderr
        @output_stream = $stdout
        @rspec_args = ARGV
      else
        @error_stream = nil
        @output_stream = nil
        @rspec_args = []
      end
    end

    def rspec_args
      if @rspec_args.nil? || @rspec_args.empty?
        Dir.glob(expand_path("spec/**/*.rb"))
      else
        @rspec_args
      end
    end

    def rspec_args=(value)
      @rspec_args = value
    end

    def dsn_string
      "Driver={SQL Server};Server=#{@db_server};Database=#{@db_name};Uid=#{@db_user};Pwd=#{@db_password}"
    end

    def db_config
      {:adapter => 'sqlserver', :mode => 'odbc', :dsn => dsn_string}
    end
  end
end
