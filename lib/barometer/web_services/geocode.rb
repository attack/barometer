module Barometer
  #
  # Web Service: Geocode
  #
  # uses Google Maps Geocoding service
  #
  class WebService::Geocode < WebService

    def self.fetch(query)
      converted_query = query.get_conversion(:short_zipcode, :zipcode, :postalcode, :coordinates, :icao, :geocode)
      return unless converted_query
      puts "geocoding: #{converted_query.q}" if Barometer::debug?

      query_params = {}
      query_params[:region] = converted_query.country_code
      query_params[:sensor] = 'false'

      if converted_query.format == :coordinates
        query_params[:latlng] = converted_query.q
      else
        query_params[:address] = converted_query.q
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
