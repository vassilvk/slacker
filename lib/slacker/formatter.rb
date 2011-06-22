require 'slacker'

module Slacker
  module Formatter
    def example_failure_text(example)
      text = ''
      exception = example.execution_result[:exception]
      text << "Failure/Error: #{read_failed_line(exception, example).strip}\n"
      text << "#{long_padding}#{exception.class.name << ":"}\n" unless exception.class.name =~ /RSpec/
      exception.message.split("\n").each { |line| text <<  "#{line}\n" }

      format_backtrace(example.execution_result[:exception].backtrace, example).each do |backtrace_info|
        text << "# #{backtrace_info}\n"
      end

      text
    end
  end
end
