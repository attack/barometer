module Barometer
  #
  # Web Service: Geocode
  #
  # uses Google Maps Geocoding service
  #
  class WebService::Geocode < WebService
    
    def self.fetch(query)
      raise ArgumentError unless _is_a_query?(query)
      puts "geocoding: #{query.q}" if Barometer::debug?
      
      query_params = {}
      query_params[:region] = query.country_code
      query_params[:sensor] = 'false'
      
      if query.format == :coordinates
        query_params[:latlng] = query.q
      else
        query_params[:address] = query.q
      end
      
      location = self.get(
        "http://maps.googleapis.com/maps/api/geocode/json",
        :query => query_params,
        :format => :json,
        :timeout => Barometer.timeout
      )
      location = location['results'].first if (location && location['results'])
      location ? (geo = Data::Geo.new(location)) : nil
    end
    
  end
end


