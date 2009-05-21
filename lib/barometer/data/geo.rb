module Barometer
  #
  # A simple Geo class
  # 
  # Used to store location data
  #
  class Data::Geo
    
    attr_accessor :latitude, :longitude, :query
    attr_accessor :locality, :region, :country, :country_code, :address
    
    def initialize(location=nil)
      return unless location
      raise ArgumentError unless location.is_a?(Hash)
      self.build_from_hash(location)
      self
    end
    
    # build the Geo object from a Hash
    #
    def build_from_hash(location=nil)
      return nil unless location
      raise ArgumentError unless location.is_a?(Hash)
      
      @query = location["name"]
      placemark = location["Placemark"]
      placemark = placemark.first if placemark.is_a?(Array)
      
      if placemark && placemark["Point"] && placemark["Point"]["coordinates"]
        if placemark["Point"]["coordinates"].is_a?(Array)
          @latitude = placemark["Point"]["coordinates"][1].to_f
          @longitude = placemark["Point"]["coordinates"][0].to_f
        else
          @latitude = placemark["Point"]["coordinates"].split(',')[1].to_f
          @longitude = placemark["Point"]["coordinates"].split(',')[0].to_f
        end
      end
      if placemark && placemark["AddressDetails"] && placemark["AddressDetails"]["Country"]
        if placemark["AddressDetails"]["Country"]["AdministrativeArea"]
          if placemark["AddressDetails"]["Country"]["AdministrativeArea"]["SubAdministrativeArea"]
            locality = placemark["AddressDetails"]["Country"]["AdministrativeArea"]["SubAdministrativeArea"]["Locality"]
          else
            locality = placemark["AddressDetails"]["Country"]["AdministrativeArea"]["Locality"]
          end
          if locality
            @locality = locality["LocalityName"]
          end
          @region = placemark["AddressDetails"]["Country"]["AdministrativeArea"]["AdministrativeAreaName"]
        end
        @country = placemark["AddressDetails"]["Country"]["CountryName"]
        @country_code = placemark["AddressDetails"]["Country"]["CountryNameCode"]
        @address = placemark["AddressDetails"]["Country"]["AddressLine"]
      end
    end

    def coordinates
      [@latitude, @longitude].join(',')
    end
    
    def to_s
      s = [@address, @locality, @region, @country || @country_code]
      s.delete("")
      s.compact.join(', ')
    end

  end
end