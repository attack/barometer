module Barometer
  #
  # Web Service: Timezone
  #
  # uses geonames.org to obtain the full timezone for given coordinates
  #
  class WebService::Timezone < WebService
    
    # get the full timezone for given coordinates
    #
    def self.fetch(latitude, longitude)
      return nil unless latitude && longitude
      response = self.get(
        "http://ws.geonames.org/timezone",
        :query => { :lat => latitude, :lng => longitude },
        :format => :xml,
        :timeout => Barometer.timeout
      )['geonames']['timezone']
      response ? Data::Zone.new(response['timezoneId']) : nil
    end

  end
end


