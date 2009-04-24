module Barometer
  #
  # A simple Station class
  # 
  # Used to store location information about the station that
  # gave the measurement data for a weather query
  #
  class Station
    
    attr_accessor :id, :name, :city
    attr_accessor :state_name, :state_code, :country_code, :zip_code
    attr_accessor :latitude, :longitude
    
    #def coordinates
    #  [@latitude, @longitude].join(',')
    #end
    
  end
end