require 'rubygems'
require 'httparty'

module Barometer
  #
  # Web Service Class
  #
  # This is a base class for creating web service api-consuming
  # drivers.  Each driver inherits from this class.
  # 
  # Basically, all a service is required to do is take a query
  # (ie "Paris") and return it corresponding data class
  #
  class WebService
    # all web_service drivers will use the HTTParty gem
    include HTTParty
    
    # STUB: define this method to actually retireve the data
    def self.fetch(query=nil); raise NotImplementedError; end

    private
    
    def self._is_a_query?(object=nil)
      return false unless object
      object.is_a?(Barometer::Query)
    end

  end
end 