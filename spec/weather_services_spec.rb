require 'spec_helper'

module Barometer
  describe WeatherService do
    around do |example|
      services_cache = WeatherService.services
      WeatherService.services = Utils::VersionedRegistration.new
      example.run
      WeatherService.services = services_cache
    end

    describe ".register" do
      it "adds the weather service to the list of available services" do
        expect {
          WeatherService.register(:test_weather, double(:weather_service))
        }.to change { WeatherService.services.size }.by(1)
      end

      it "registers the service for a given version" do
        weather_service = double(:weather_service)
        WeatherService.register(:test_weather, :v1, weather_service)
        expect {
          WeatherService.register(:test_weather, :v2, weather_service)
        }.to change { WeatherService.services.size }.by(1)
      end

      it "adds the block as an available weather service" do
        expect {
          WeatherService.register(:test_weather) do
            Response.new.tap do |r|
              r.current = Response::Current.new
              r.current.temperature = 30
            end
          end
        }.to change { WeatherService.services.size }.by(1)

        expect( WeatherService.new(:test_weather).measure(build_query).current.temperature.to_i ).to eq 30
      end

      it "raises an error if no service or block given" do
        expect {
          WeatherService.register(:test_weather)
        }.to raise_error(ArgumentError)
      end

      it "allows the serivce to be referenced by key" do
        expect( WeatherService.services ).not_to have_key :test_weather
        WeatherService.register(:test_weather, double(:weather_service))
        expect( WeatherService.services ).to have_key :test_weather
      end

      it "only registers a key once" do
        weather_service = double(:weather_service)
        WeatherService.register(:test_weather, weather_service)
        expect {
          WeatherService.register(:test_weather, weather_service)
        }.not_to change { WeatherService.services.size }
      end

      it "only registers a version once" do
        weather_service = double(:weather_service)
        WeatherService.register(:test_weather, :v1, weather_service)
        expect {
          WeatherService.register(:test_weather, :v1, weather_service)
        }.not_to change { WeatherService.services.size }
      end
    end

    describe ".source" do
      it "returns a registered source" do
        test_weather = double(:test_weather)
        WeatherService.register(:test_weather, test_weather)

        expect( WeatherService.source(:test_weather) ).to eq test_weather
      end

      it "raises an error if the source does not exist" do
        expect {
          WeatherService.source(:test_weather)
        }.to raise_error(WeatherService::NotFound)
      end

      it "raises an error if the version does not exist" do
        expect {
          WeatherService.source(:test_weather, :v1)
        }.to raise_error(WeatherService::NotFound)
      end

      context "when multiple versions are registered" do
        it "returns the requested version" do
          test_weather = double(:test_weather)
          other_weather = double(:other_weather)
          WeatherService.register(:test_weather, nil, test_weather)
          WeatherService.register(:test_weather, :v1, other_weather)

          expect( WeatherService.source(:test_weather) ).to eq test_weather
          expect( WeatherService.source(:test_weather, nil) ).to eq test_weather
          expect( WeatherService.source(:test_weather, :v1) ).to eq other_weather
        end
      end
    end
  end
end
