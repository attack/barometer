require 'nokogiri'
require 'nori'
require 'rexml/document'

module Barometer
  module Utils
    module XmlReader
      def self.parse(xml, *nodes_to_remove)
        xml_reader = Nori.new(
          parser: :nokogiri,
          strip_namespaces: true
        )
        output = xml_reader.parse(xml)

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
