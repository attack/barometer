require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WeatherService do
  before do
    @services_cache = Barometer::WeatherService.services
    Barometer::WeatherService.services = {}
  end

  describe ".register" do
    it "adds the weather service to the list of available services" do
      expect {
        Barometer::WeatherService.register(:test_weather, double(:weather_service))
      }.to change { Barometer::WeatherService.services.count }.by(1)
    end

    it "adds the block as an available weather service" do
      expect {
        Barometer::WeatherService.register(:test_weather) do
          m = Barometer::Measurement.new
          m.current.temperature = 30
          m
        end
      }.to change { Barometer::WeatherService.services.count }.by(1)

      Barometer::WeatherService.measure(:test_weather, "test").current.temperature.to_i.should == 30
    end

    it "raises an error if no service or block given" do
      expect {
        Barometer::WeatherService.register(:test_weather)
      }.to raise_error(ArgumentError)
    end

    it "allows the serivce to be referenced by key" do
      Barometer::WeatherService.services.should_not have_key :test_weather
      Barometer::WeatherService.register(:test_weather, double(:weather_service))
      Barometer::WeatherService.services.should have_key :test_weather
    end

    it "only registers a key once" do
      weather_service = double(:weather_service)
      Barometer::WeatherService.register(:test_weather, weather_service)
      expect {
        Barometer::WeatherService.register(:test_weather, weather_service)
      }.not_to change { Barometer::WeatherService.services.count }
    end
  end

  describe ".source" do
    it "returns a registered source" do
      test_weather = double(:test_weather)
      Barometer::WeatherService.register(:test_weather, test_weather)

      Barometer::WeatherService.source(:test_weather).should == test_weather
    end

    it "raises an error if the source does not exist" do
      expect {
        Barometer::WeatherService.source(:test_weather)
      }.to raise_error(Barometer::WeatherService::NotFound)
    end
  end

  describe ".measure" do
    let(:test_weather) { double(:test_weather) }
    let(:query) { double(:query) }
    let(:test_measurement) { Barometer::Measurement.new }

    before do
      test_weather.stub(:call).and_return(test_measurement)
      Barometer::WeatherService.register(:test_weather, test_weather)
    end

    it "calls the requested weather service" do
      test_weather.should_receive(:call)
      Barometer::WeatherService.measure(:test_weather, query)
    end

    it "passes along query and options" do
      test_weather.should_receive(:call).with(query)
      Barometer::WeatherService.measure(:test_weather, query)
    end

    describe "timing information" do
      it "adds measurement_started_at" do
        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.measurement_started_at.should_not be_nil
        measurement.measurement_started_at.should be_a(::Time)
      end

      it "adds measurement_ended_at" do
        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.measurement_ended_at.should_not be_nil
        measurement.measurement_ended_at.should be_a(::Time)
      end
    end

    describe "source information" do
      it "adds the source" do
        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.source.should == :test_weather
      end
    end

    describe "error handling" do
      it "adds code 200 if no errors" do
        test_measurement.stub(:complete? => true)

        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.status_code.should == 200
      end

      it "adds code 204 if service has no data" do
        test_measurement.stub(:complete? => false)

        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.status_code.should == 204
      end

      it "adds code 401 if required key not provided" do
        test_weather.stub(:call).and_raise(Barometer::WeatherService::KeyRequired)

        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.status_code.should == 401
      end

      it "adds code 406 if query format unsupported" do
        test_weather.stub(:call).and_raise(Barometer::Query::ConversionNotPossible)

        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.status_code.should == 406
      end

      it "adds code 406 if query region unsupported" do
        test_weather.stub(:call).and_raise(Barometer::Query::UnsupportedRegion)

        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.status_code.should == 406
      end

      it "adds code 408 if service unavailable (timeout)" do
        test_weather.stub(:call).and_raise(Timeout::Error)

        measurement = Barometer::WeatherService.measure(:test_weather, query)
        measurement.status_code.should == 408
      end
    end
  end

  after do
    Barometer::WeatherService.services = @services_cache
  end
end
