module Barometer
  #
  # A simple Location class
  #
  # Used to store location information about the station that
  # gave the measurement data for a weather query, or the location
  # that was queried
  #
  class Data::Location

    attr_accessor :id, :name, :city
    attr_accessor :state_name, :state_code, :country, :country_code, :zip_code
    attr_accessor :latitude, :longitude

    def coordinates
      [@latitude, @longitude].join(',')
    end

    def to_s
      [@name, @city, @state_name || @state_cocde,
        @country || @country_code].compact.join(', ')
    end

  end
end
