require 'slacker/formatter'
require 'rspec/core/formatters/progress_formatter'

module Slacker
  class CommandLineFormatter < RSpec::Core::Formatters::ProgressFormatter
    include Slacker::Formatter

    def initialize(output)
      super(output)
      @failed_examples_count = 0
      @passed_examples_count = 0
    end

    def example_passed(example)
      process_example_debug_output(example, false)
      super(example)
    end

    def example_failed(example)
      process_example_debug_output(example, true)
      super(example)
    end

private

    def process_example_debug_output(example, example_failed)
      if example_failed
        @failed_examples_count += 1
        debug_output(example, Slacker.configuration.expand_path('debug/failed_examples'), @failed_examples_count, example_failed)
      else
        @passed_examples_count += 1
        debug_output(example, Slacker.configuration.expand_path('debug/passed_examples'), @passed_examples_count, example_failed)
      end
    end

    def debug_output(example, out_folder, file_number, example_failed)
      # Write out the SQL
      File.open("#{out_folder}/example_#{'%03d' % file_number}.sql", 'w') do |out_file|
        out_file.write(get_formatted_example_sql(example, example_failed))
      end
    end

    def get_formatted_example_sql(example, example_failed)
      sql = <<EOF
-- Example "#{example.metadata[:full_description]}"
-- #{example.metadata[:location]}
-- Executed at #{example.metadata[:execution_result][:started_at]}

#{example.metadata[:sql]}

--               SLACKER RESULTS
-- *******************************************
#{example_failed ? example_failure_text(example).split("\n").collect{|line| '-- ' + line}.join("\n") : '--              Example Passed OK'}
-- *******************************************
EOF
      sql.strip
    end
  end
end
