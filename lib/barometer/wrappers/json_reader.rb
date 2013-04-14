require 'yajl'

module Barometer
  module JsonReader
    def self.parse(json, *nodes_to_remove)
      json_reader = Yajl::Parser.new
      output = json_reader.parse(json)

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
