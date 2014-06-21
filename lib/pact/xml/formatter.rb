module Pact
  module XML

    class DiffFormatter

      def initialize diff, options = {}
        @diff = diff
        @colour = options.fetch(:colour, false)
      end

      def self.call diff, options = {colour: Pact.configuration.color_enabled}
        new(diff, options).call
      end

      def call
        # diff formatting code here
      end

      private



    end

  end
end