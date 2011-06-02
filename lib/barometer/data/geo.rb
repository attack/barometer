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
      placemark = find_most_accurate(placemark)
      
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
        country = placemark["AddressDetails"]["Country"]
        if country["AdministrativeArea"]
          ad_area = country["AdministrativeArea"]
          if ad_area["SubAdministrativeArea"]
            @locality = ad_area["SubAdministrativeArea"]["Locality"]["LocalityName"]
          elsif ad_area["DependentLocality"] && ad_area["DependentLocality"]["DependentLocalityName"]
            @locality = ad_area["DependentLocality"]["DependentLocalityName"]
          elsif ad_area["Locality"] && ad_area["Locality"]["LocalityName"]
            @locality = ad_area["Locality"]["LocalityName"]
          else
            @locality = ""
          end
          @region = ad_area["AdministrativeAreaName"]
        end
        @country = country["CountryName"]
        @country_code = country["CountryNameCode"]
        @address = country["AddressLine"]
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
    
    # geocode may return multiple results, use the first one that has the best accuracy
    #
    def find_most_accurate(placemark)
      return placemark unless placemark.is_a?(Array)
      most_accurate = placemark.first
      placemark.each do |p|
        most_accurate = p if p && p["AddressDetails"] && p["AddressDetails"]["Accuracy"] && p["AddressDetails"]["Accuracy"].to_i < most_accurate["AddressDetails"]["Accuracy"].to_i
      end
      most_accurate
    end

  end
end