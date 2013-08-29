module Barometer
  class Base
    attr_reader :query, :weather

    def initialize(query, units=:metric)
      @query = Query.new(query)
      @units = units
      @weather = Weather.new(units)
    end

    def measure
      record_time do
        measure_until_successful or raise OutOfSources
      end
      @weather
    end

    private

    def record_time
      @weather.start_at = Time.now.utc
      yield
      @weather.end_at = Time.now.utc
    end

    def measure_until_successful
      Utils::ConfigReader.take_level_while do |level|
        measure_using_all_services_in_level(level)
        measure_with_next_level?
      end
      success?
    end

    def measure_using_all_services_in_level(level)
      Utils::ConfigReader.services(level) do |source, config|
        options = { :metric => metric }
        options.merge!(config) if config
        measure_and_record(source, options)
      end
    end

    def measure_and_record(source, options)
      @weather.responses << WeatherService.measure(source, query, options)
    end

    def success?
      @weather.success?
    end

    def measure_with_next_level?
      !success?
    end

    def metric
      @units == :metric
    end
  end
end
