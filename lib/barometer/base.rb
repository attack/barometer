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
        version = extract_version(config)
        options = build_options(config)
        measure_and_record(source, version, options)
      end
    end

    def extract_version(config)
      return unless config
      config[:version]
    end

    def build_options(config)
      {:metric => metric}.merge(config || {})
    end

    def measure_and_record(source, version, options)
      @weather.responses << WeatherService.new(source, version).measure(query, options)
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
