require_relative '../spec_helper'

module Barometer
  describe WeatherService::Base do
    around do |example|
      services_cache = WeatherService.services
      WeatherService.services = Utils::VersionedRegistration.new
      example.run
      WeatherService.services = services_cache
    end

    describe "#measure" do
      let(:test_weather) { double(:test_weather) }
      let(:query) { build_query }
      let(:options) { {} }
      let(:test_response) { Response.new }

      before do
        test_weather.stub(call: test_response)
        WeatherService.register(:test_weather, test_weather)
      end

      it "calls the requested weather service" do
        WeatherService.new(:test_weather).measure(query)
        expect( test_weather ).to have_received(:call).with(query, {})
      end

      it "calls the requested version of the weather service" do
        test_weather_v2 = double(:test_weather, call: test_response)
        WeatherService.register(:test_weather, :v2, test_weather_v2)

        WeatherService.new(:test_weather, :v2).measure(query)

        expect( test_weather_v2 ).to have_received(:call).with(query, {})
      end

      it "passes along query and options" do
        WeatherService.new(:test_weather).measure(query, options)
        expect( test_weather ).to have_received(:call).with(query, options)
      end

      describe "timing information" do
        it "adds response_started_at" do
          response = WeatherService.new(:test_weather).measure(query)
          expect( response.response_started_at ).to be
        end

        it "adds response_ended_at" do
          response = WeatherService.new(:test_weather).measure(query)
          expect( response.response_ended_at ).to be
        end
      end

      describe "source information" do
        it "adds the source" do
          response = WeatherService.new(:test_weather).measure(query)
          expect( response.source ).to eq :test_weather
        end

        it "adds the source weight" do
          response = WeatherService.new(:test_weather).measure(query, {weight: 10})
          expect( response.weight ).to eq 10
        end

        it "adds the default source weight" do
          response = WeatherService.new(:test_weather).measure(query)
          expect( response.weight ).to eq 1
        end
      end

      describe "error handling" do
        it "adds code 200 if no errors" do
          test_response.stub(complete?: true)

          response = WeatherService.new(:test_weather).measure(query)
          expect( response.status_code ).to eq 200
        end

        it "adds code 204 if service has no data" do
          test_response.stub(complete?: false)

          response = WeatherService.new(:test_weather).measure(query)
          expect( response.status_code ).to eq 204
        end

        it "adds code 401 if required key not provided" do
          test_weather.stub(:call).and_raise(WeatherService::KeyRequired)

          response = WeatherService.new(:test_weather).measure(query)
          expect( response.status_code ).to eq 401
        end

        it "adds code 406 if query format unsupported" do
          test_weather.stub(:call).and_raise(Query::ConversionNotPossible)

          response = WeatherService.new(:test_weather).measure(query)
          expect( response.status_code ).to eq 406
        end

        it "adds code 406 if query region unsupported" do
          test_weather.stub(:call).and_raise(Query::UnsupportedRegion)

          response = WeatherService.new(:test_weather).measure(query)
          expect( response.status_code ).to eq 406
        end

        it "adds code 408 if service unavailable (timeout)" do
          test_weather.stub(:call).and_raise(Timeout::Error)

          response = WeatherService.new(:test_weather).measure(query)
          expect( response.status_code ).to eq 408
        end
      end
    end
  end
end
