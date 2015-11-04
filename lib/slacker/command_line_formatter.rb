require 'slacker/formatter'
require 'rspec/core/formatters/progress_formatter'

module Slacker
  class CommandLineFormatter < RSpec::Core::Formatters::ProgressFormatter
    include Slacker::Formatter
    RSpec::Core::Formatters.register self, :example_passed, :example_failed

    def initialize(output)
      super(output)
      @failed_examples_count = 0
      @passed_examples_count = 0
    end

    def example_passed(notification)
      super(notification)
      process_example_debug_output(notification, false)
    end

    def example_failed(notification)
      super(notification)
      process_example_debug_output(notification, true)
    end

private

    def process_example_debug_output(notification, example_failed)
      if example_failed
        @failed_examples_count += 1
        debug_output(notification, Slacker.configuration.expand_path('debug/failed_examples'), @failed_examples_count, example_failed)
      else
        @passed_examples_count += 1
        debug_output(notification, Slacker.configuration.expand_path('debug/passed_examples'), @passed_examples_count, example_failed)
      end
    end

    def debug_output(notification, out_folder, file_number, example_failed)
      # Write out the SQL
      File.open("#{out_folder}/example_#{'%03d' % file_number}.sql", 'w') do |out_file|
        out_file.write(get_formatted_example_sql(notification, example_failed))
      end
    end

    def get_formatted_example_sql(notification, example_failed)
      example = notification.example
      sql = <<EOF
-- Example "#{example.metadata[:full_description]}"
-- #{example.metadata[:location]}
-- Executed at #{example.execution_result.started_at}

#{example.metadata[:sql]}

--               SLACKER RESULTS
-- *******************************************
#{example_failed ? example_failure_text(notification).split("\n").collect{|line| '-- ' + line}.join("\n") : '--              Example Passed OK'}
-- *******************************************
EOF
      sql.strip
    end
  end
end
