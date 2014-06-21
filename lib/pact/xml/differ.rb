module Pact
  module XML

    class Differ

      def initialize expected, actual, options = {}
        @expected = expected
        @actual = actual
        @options = options
      end

      def self.call expected, actual, options = {}
        new(expected, actual, options).call
      end

      def call
        # diffing code here
      end

    end

  end
end