module Barometer
  class Weather
    attr_accessor :responses
    attr_accessor :start_at, :end_at

    def initialize(units=:metric)
      @units = units
      @responses = []
    end

    def source(source)
      responses.detect{|response| response.source == source}
    end

    def success?
      responses.any?(&:success?)
    end

    def current
      successful_responses.first.current if successful_responses.any?
    end

    def forecast
      successful_responses.first.forecast if successful_responses.any?
    end

    def today
      successful_responses.first.forecast[0] if successful_responses.any?
    end

    def tomorrow
      successful_responses.first.forecast[1] if successful_responses.any?
    end

    def for(query)
      successful_responses.first.for(query) if successful_responses.any?
    end

    def temperature; average(:temperature, Data::Temperature); end
    def dew_point; average(:dew_point, Data::Temperature); end
    def heat_index; average(:heat_index, Data::Temperature); end
    def wind_chill; average(:wind_chill, Data::Temperature); end
    def pressure; average(:pressure, Data::Pressure); end
    def visibility; average(:visibility, Data::Distance); end
    def wind; average(:wind, Data::Vector); end
    def humidity; average(:humidity); end

    private

    def successful_responses
      @successful_responses ||= responses.select(&:success?)
    end

    def average(field, data_class=nil)
      return if successful_responses.empty?
      value = raw_average(field)
      data_class ? data_class.new(@units, value) : value
    end

    def raw_average(field)
      weighted_value(field) / total_weight(field)
    end

    def total_weight(field)
      successful_responses.inject(0) do |sum, response|
        sum + (response.current.send(field) ? response.weight : 0)
      end
    end

    def weighted_value(field)
      successful_responses.inject(0) do |sum, response|
        sum + (value_in_correct_units(response, field).to_f * response.weight)
      end
    end

    def value_in_correct_units(response, field)
      value = response.current.send(field)
      value = value.send(@units) if value.respond_to?(@units)
      value
    end
  end
end
