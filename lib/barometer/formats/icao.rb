module Barometer
  #
  # ICAO Format
  # 
  # International Civil Aviation Organization
  # eg: KLAX (Los Angeles Airport) 
  #
  class Query::Icao < Query::Format
  
    def self.regex
      # allow any 3 or 4 letter word ... unfortunately this means some locations
      # (ie Utah, Goa, Kiev, etc) will be detected as ICAO.  This won't matter for
      # returning weather results ... it will just effect what happens to the query.
      # For example, wunderground will accept :icao above :coordinates and :geocode,
      # which means that a city like Kiev would normally get converted to :coordinates
      # but in this case it will be detected as :icao so it will be passed as is.
      # Currently, only wunderground accepts ICAO, and they process ICAO the same as a
      # city name, so it doesn't matter.
      /^[A-Za-z]{3,4}$/
    end
  
    def self.format
      :icao
    end
  
    # todo, the fist letter in a 4-letter icao can designate country:
    # c=canada
    # k=usa
    # etc...
    # def self.country_code(query=nil)
    #   return unless icao_code.is_a?(String)
    #   country_code = nil
    #   if icao_code.size == 4
    #     case icao_code.first_letter
    #     when "C"
    #       country_code = "CA"
    #     when "K"
    #       country_code = "US"
    #     end
    #     if coutry_code.nil?
    #       case icao_code.first_two_letters
    #       when "ET"
    #         country_code = "GERMANY"
    #       end
    #     end
    #   end  
    #   country_code
    # end
  
  end
end