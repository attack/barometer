require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Barometer
  describe Base do
    let(:barometer) { Base.new('Foobar Falls') }

    describe "#measure" do
      let(:keys) { {:fake_secret => 'ABC123'} }
      let(:response_one) { Response.new.tap{|r| r.stub(:complete? => true)} }
      let(:response_two) { Response.new.tap{|r| r.stub(:complete? => true)} }
      let(:weather_service_one) { double(:weather_service_one, :call => response_one) }
      let(:weather_service_two) { double(:weather_service_two, :call => response_two) }

      around do |example|
        services_cache = WeatherService.services
        cached_config = Barometer.config
        WeatherService.services = Utils::VersionedRegistration.new

        example.run

        WeatherService.services = services_cache
        Barometer.config = cached_config
      end

      before do
        Barometer.config = { 1 => {:test_one => {:keys => keys} } }
        WeatherService.register(:test_one, weather_service_one)
        WeatherService.register(:test_two, weather_service_two)
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
        before { response_one.stub(:success? => true) }

        it "measures the weather" do
          WeatherService.stub(:measure => response_one)

          barometer.measure

          expect( WeatherService ).to have_received(:measure).
            with(:test_one, barometer.query, { :metric => true, :keys => keys })
        end

        it "adds the result to weather.responses" do
          weather = barometer.measure
          expect( weather.responses ).to include response_one
        end

        context "and another weather service is configured for the same service_level" do
          before { Barometer.config = { 1 => [:test_one, :test_two] } }

          it "measures the weather again" do
            WeatherService.stub(:measure).and_return(response_one, response_two)

            barometer.measure

            expect( WeatherService ).to have_received(:measure).
              with(:test_two, barometer.query, anything)
          end

          it "adds the result to weather.responses" do
            weather = barometer.measure
            expect( weather.responses ).to include response_two
          end
        end

        context "and another weather service is configured for the next service_level" do
          before { Barometer.config = { 1 => :test_one, 2 => :test_two } }

          it "does not measure the weather again" do
            WeatherService.stub(:measure => response_one)

            barometer.measure

            expect( WeatherService ).not_to have_received(:measure).
              with(:test_two, barometer.query, anything)
          end
        end
      end

      context "when the first weather service is not successful" do
        before { response_one.stub(:success? => false) }

        context "and there are no other weather services configured" do
          before { Barometer.config = { 1 => :test_one } }

          it "raises an error" do
            expect {
              barometer.measure
            }.to raise_error(OutOfSources)
          end
        end

        context "and another weather service is configured for the next service_level" do
          before do
            Barometer.config = { 1 => [:test_one, :test_two], 2 => :test_two }
            response_two.stub(:success? => true)
          end

          it "measures the weather using the next service_level" do
            WeatherService.stub(:measure).and_return(response_one, response_two)

            barometer.measure

            expect( WeatherService ).to have_received(:measure).
              with(:test_two, barometer.query, anything)
          end

          it "adds the result to weather.responses" do
            weather = barometer.measure
            expect( weather.responses ).to include response_two
          end
        end
      end
    end
  end
end
