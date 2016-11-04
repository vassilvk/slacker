require 'logger'
require 'rspec/core'
require 'slacker/rspec_monkey'
require 'slacker/rspec_ext'
require 'slacker/string_helper'
require 'odbc'

module Slacker
  class Application
    attr_reader :target_folder_structure

    SQL_OPTIONS = <<EOF
set textsize 2147483647;
set language us_english;
set dateformat mdy;
set datefirst 7;
set lock_timeout -1;
set quoted_identifier on;
set arithabort on;
set ansi_null_dflt_on on;
set ansi_warnings on;
set ansi_padding on;
set ansi_nulls on;
set concat_null_yields_null on;
EOF

    def initialize(configuration)
      @configuration = configuration
      @target_folder_structure = ['data', 'debug', 'debug/passed_examples', 'debug/failed_examples', 'sql', 'spec', 'lib', 'lib/helpers']
      @error_message = ''
      @database = ODBC::Database.new
    end

    def print_connection_message
      puts "#{@configuration.db_name} (#{@configuration.db_server})" if @configuration.console_enabled
    end

    # Customize RSpec and run it
    def run
      begin
        error = catch :error_exit do
          print_connection_message
          test_folder_structure
          cleanup_folders
          configure
          run_rspec
          false #Return false to error
        end
      ensure
        cleanup_after_run
      end

      if @configuration.console_enabled
        puts @error_message if error
      else
        raise @error_message if error
      end
    end

    def run_rspec
      RSpec::Core::Runner.disable_autorun!

      RSpec::Core::Runner.run(@configuration.rspec_args,
        @configuration.error_stream,
        @configuration.output_stream)
    end

    # Configure Slacker
    def configure
      configure_db
      configure_rspec
      configure_misc
    end

    def cleanup_after_run
      @database.disconnect if (@database && @database.connected?)
    end

    def cleanup_folders
      cleanup_folder('debug/passed_examples')
      cleanup_folder('debug/failed_examples')
    end

    def cleanup_folder(folder)
      folder_path = get_path(folder)
      Dir.new(folder_path).each{|file_name| File.delete("#{folder_path}/#{file_name}") if File.file?("#{folder_path}/#{file_name}")}
    end

    # Get a path relative to the current path
    def get_path(path)
      @configuration.expand_path(path)
    end

    def configure_misc
      # Add the lib folder to the load path
      $:.push get_path('lib')
      # Mixin the helper modules
      mixin_helpers
    end

    # Mix in the helper modules
    def mixin_helpers
      helpers_dir = get_path('lib/helpers')
      $:.push helpers_dir
      Dir.new(helpers_dir).each do |file_name|
        if file_name =~ /\.rb$/
          require file_name
          module_class = Slacker::StringHelper.constantize(Slacker::StringHelper.camelize(file_name.gsub(/\.rb$/,'')))
          RSpec.configure do |config|
            config.include(module_class)
          end
          Slacker.mixin_module(module_class)
        end
      end
    end

    # Configure database connection
    def configure_db
      drv = ODBC::Driver.new
      drv.name = 'Driver1'
      drv.attrs.tap do |a|
        a['Driver'] = '{SQL Server}'
        a['Server']= @configuration.db_server
        a['Database']= @configuration.db_name
        a['Uid'] = @configuration.db_user
        a['Pwd'] = @configuration.db_password
        a['TDS_Version'] = '7.0' #Used by the linux driver
      end

      begin
        @database.drvconnect(drv)
      rescue ODBC::Error => e
        throw_error("#{e.class}: #{e.message}")
      end
    end

    # Run a script against the currently configured database
    def query_script(sql)
      results = []
      begin
        st = @database.run(sql)
        begin
          if st.ncols > 0
            rows = []
            st.each_hash(false, true){|row| rows << row}
            results << rows
          end
        end while(st.more_results)
      ensure
        st.drop unless st.nil?
      end
      results.count > 1 ? results : results.first
    end

    # Customize RSpec
    def configure_rspec
      before_proc = lambda do |example|
        # Initialize the example's SQL
        example.metadata[:sql] = ''
        Slacker.query_script(example, 'begin transaction;', 'Initiate the example script')
        Slacker.query_script(example, SQL_OPTIONS, 'Set default options')
      end

      after_proc = lambda do |example|
        Slacker.query_script(example, 'if @@trancount > 0 rollback transaction;', 'Rollback the changes made by the example script')
      end

      # Reset RSpec through a monkey-patched method
      RSpec.slacker_reset

      RSpec.configure do |config|
        
        # Expose the current example to the ExampleGroup extension
        # This is necessary in order to have this work with RSpec 3
        config.expose_current_running_example_as :example
        
        # Global "before" hooks to begin a transaction
        config.before(:each) do
          before_proc.call(example)
        end

        # Global "after" hooks to rollback a transaction
        config.after(:each) do
          after_proc.call(example)
        end

        # Slacker's RSpec extension module
        config.include(Slacker::RSpecExt)
        config.extend(Slacker::RSpecExt)

        config.output_stream = @configuration.output_stream
        config.error_stream = @configuration.error_stream

        config.add_formatter(Slacker::CommandLineFormatter)
     end
    end

    # Tests the current folder's structure
    def test_folder_structure()
      target_folder_structure.each do |dir|
        if !File.directory?(get_path(dir))
          throw_error("Cannot find directory \"#{get_path(dir)}\"")
        end
      end
    end

    def throw_error(msg)
      @error_message = msg
      throw :error_exit, true
    end
  end
end