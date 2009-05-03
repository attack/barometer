module Graticule
  class Location
    
    attr_accessor :country_code, :address_line
    
    def attributes
      [:latitude, :longitude, :street, :locality, :region, :postal_code, :country, :precision, :cuntry_code, :address_line].inject({}) do |result,attr|
        result[attr] = self.send(attr) unless self.send(attr).blank?
        result
      end
    end
    
  end
  
  module Geocoder
    
    class Google < Rest
      
      # Locates +address+ returning a Location
      # add ability to bias towards a country
      def locate(address, country_bias=nil)
        get :q => (address.is_a?(String) ? address : location_from_params(address).to_s),
          :gl => country_bias
      end
      
      private
      
      # Extracts a Location from +xml+.
      def parse_response(xml) #:nodoc:
        longitude, latitude, = xml.elements['/kml/Response/Placemark/Point/coordinates'].text.split(',').map { |v| v.to_f }
        returning Location.new(:latitude => latitude, :longitude => longitude) do |l|
          address = REXML::XPath.first(xml, '//xal:AddressDetails',
            'xal' => "urn:oasis:names:tc:ciq:xsdschema:xAL:2.0")
 
          if address
            l.street = value(address.elements['.//ThoroughfareName/text()'])
            l.locality = value(address.elements['.//LocalityName/text()'])
            l.region = value(address.elements['.//AdministrativeAreaName/text()'])
            l.postal_code = value(address.elements['.//PostalCodeNumber/text()'])
            l.country = value(address.elements['.//CountryName/text()'])
            l.country_code = value(address.elements['.//CountryNameCode/text()'])
            l.address_line = value(address.elements['.//AddressLine/text()'])
            l.precision = PRECISION[address.attribute('Accuracy').value.to_i] || :unknown
          end
        end
      end
      
    end
    
  end
end