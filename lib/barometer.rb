$:.unshift(File.dirname(__FILE__))

require 'barometer/base'
require 'barometer/query'
require 'barometer/weather'
require 'barometer/services'
require 'barometer/data'
 
module Barometer
  
  def self.new(query=nil)
    Barometer::Base.new(query)
  end
  
  def self.selection=(selection=nil)
    Barometer::Base.selection = selection
  end
  
  # shortcut to Barometer::Service.source method
  # allows Barometer.source(:wunderground)
  def self.source(source)
    Barometer::Service.source(source)
  end
  
end

