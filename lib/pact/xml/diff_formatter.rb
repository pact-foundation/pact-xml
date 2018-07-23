# frozen_string_literal: true

require 'term/ansicolor'

module Pact
  module XML
    NEWLINE = "\n"
    C = ::Term::ANSIColor

    # Formats list of differences into string
    class DiffFormatter
      def self.color(text, color, options)
        options.fetch(:colour, false) ? C.color(color, text) : text
      end

      def self.make_line(diff, options)
        "EXPECTED : #{color diff.expected, :red, options} #{NEWLINE}" \
        "ACTUAL   : #{color diff.actual, :green, options} #{NEWLINE}" \
        "MESSAGE  : #{diff.message}"
      end

      def self.call(
          result,
          options = { colour: Pact.configuration.color_enabled }
        )
        diff = result[:body]
        return '' if diff.nil?
        diff.map { |d| make_line d, options }.join NEWLINE
      end
    end
  end
end
