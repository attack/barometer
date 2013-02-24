module Barometer
  class Data::Location
    attr_accessor :id, :name, :city
    attr_accessor :state_name, :state_code, :country, :country_code, :zip_code
    attr_accessor :latitude, :longitude

    def coordinates
      [latitude, longitude].join(',')
    end

    def nil?
      %w{name city state_name state_code country
      country_code zip_code latitude longitude}.all?{ |field| send(field).nil? }
    end

    def to_s
      [name, city, state_name || state_code,
        country || country_code].compact.join(', ')
    end
  end
end
