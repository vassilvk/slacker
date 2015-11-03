require 'slacker'

module Slacker
  module Formatter
    def example_failure_text(notification)
      text = ''
      exception = notification.example.execution_result.exception
      text << notification.message_lines.join("\n").strip << "\n"
      text << notification.formatted_backtrace.join("\n")

      text
    end
  end
end
