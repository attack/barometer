require 'nokogiri'
require 'nori'

module Barometer
  module XmlReader
    def self.parse(xml, *nodes_to_remove)
      xml_reader = Nori.new(
        :parser => :nokogiri,
        :strip_namespaces => true
      )
      output = xml_reader.parse(xml)

      nodes_to_remove.each do |node|
        output = output.fetch(node, output)
      end

      output
    end
  end
end
