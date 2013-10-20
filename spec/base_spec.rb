require 'spec_helper'

module Barometer
  describe Base do
    let(:query) { build_query }
    let(:barometer) { Base.new(query) }

    describe "#measure" do
      let(:keys) { {fake_secret: 'ABC123'} }
      let(:response_foo) { Response.new.tap{|r| r.stub(complete?: true)} }
      let(:response_bar) { Response.new.tap{|r| r.stub(complete?: true)} }
      let(:foo_weather_service) { double(:weather_service, call: response_foo) }
      let(:bar_weather_service) { double(:weather_service, call: response_bar) }

      around do |example|
        services_cache = WeatherService.services
        cached_config = Barometer.config
        WeatherService.services = Utils::VersionedRegistration.new

        example.run

        WeatherService.services = services_cache
        Barometer.config = cached_config
      end

      before do
        Barometer.config = {1 => {foo: {keys: keys}}}
        WeatherService.register(:foo, foo_weather_service)
        WeatherService.register(:bar, bar_weather_service)
      end

      it "returns a Weather object" do
        expect( barometer.measure ).to be_a Weather
      end

      it "records starting and ending timestamps" do
        weather = barometer.measure
        expect( weather.start_at ).to be
        expect( weather.end_at ).to be
      end

      context "when the first weather service is successful" do
        before { response_foo.stub(success?: true) }

        it "measures the weather" do
          barometer.measure
          expect( foo_weather_service ).to have_received(:call).
            with(an_instance_of(Query::Base), {keys: keys})
        end

        it "adds the result to weather.responses" do
          weather = barometer.measure
          expect( weather.responses ).to include response_foo
        end

        context "and another weather service is configured for the same service_level" do
          before { Barometer.config = {1 => [:foo, :bar]} }

          it "measures the weather again" do
            barometer.measure
            expect( bar_weather_service ).to have_received(:call).
              with(an_instance_of(Query::Base), {})
          end

          it "adds the result to weather.responses" do
            weather = barometer.measure
            expect( weather.responses ).to include response_bar
          end
        end

        context "and another weather service is configured for the next service_level" do
          before { Barometer.config = {1 => :foo, 2 => :bar} }

          it "does not measure the weather again" do
            barometer.measure
            expect( bar_weather_service ).not_to have_received(:call)
          end
        end
      end

      context "when the first weather service is not successful" do
        before { response_foo.stub(success?: false) }

        context "and there are no other weather services configured" do
          before { Barometer.config = {1 => :foo} }

          it "raises an error" do
            expect {
              barometer.measure
            }.to raise_error(OutOfSources)
          end
        end

        context "and another weather service is configured for the next service_level" do
          before do
            Barometer.config = {1 => [:foo, :bar], 2 => :bar}
            response_bar.stub(success?: true)
          end

          it "measures the weather using the next service_level" do
            barometer.measure
            expect( bar_weather_service ).to have_received(:call).
              with(an_instance_of(Query::Base), {})
          end

          it "adds the result to weather.responses" do
            weather = barometer.measure
            expect( weather.responses ).to include response_bar
          end
        end
      end
    end
  end
end
