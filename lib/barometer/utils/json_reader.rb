require 'json' unless defined?(JSON)

module Barometer
  module Utils
    module JsonReader
      def self.parse(json, *nodes_to_remove)
        output = JSON.parse(json)

        nodes_to_remove.each do |node|
          output = output.fetch(node, output)
        end

        if block_given? && output
          output = yield(output)
        end

        output
      end
    end
  end
end
