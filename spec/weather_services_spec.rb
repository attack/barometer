require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Barometer::WeatherService do
  before do
    @services_cache = Barometer::WeatherService.services
    Barometer::WeatherService.services = Barometer::Utils::VersionedRegistration.new
  end

  describe ".register" do
    it "adds the weather service to the list of available services" do
      expect {
        Barometer::WeatherService.register(:test_weather, double(:weather_service))
      }.to change { Barometer::WeatherService.services.size }.by(1)
    end

    it "registers the service for a given version" do
      weather_service = double(:weather_service)
      Barometer::WeatherService.register(:test_weather, :v1, weather_service)
      expect {
        Barometer::WeatherService.register(:test_weather, :v2, weather_service)
      }.to change { Barometer::WeatherService.services.size }.by(1)
    end

    it "adds the block as an available weather service" do
      expect {
        Barometer::WeatherService.register(:test_weather) do
          m = Barometer::Response.new
          m.current.temperature = 30
          m
        end
      }.to change { Barometer::WeatherService.services.size }.by(1)

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
      }.not_to change { Barometer::WeatherService.services.size }
    end

    it "only registers a version once" do
      weather_service = double(:weather_service)
      Barometer::WeatherService.register(:test_weather, :v1, weather_service)
      expect {
        Barometer::WeatherService.register(:test_weather, :v1, weather_service)
      }.not_to change { Barometer::WeatherService.services.size }
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

    it "raises an error if the version does not exist" do
      expect {
        Barometer::WeatherService.source(:test_weather, :v1)
      }.to raise_error(Barometer::WeatherService::NotFound)
    end

    context "when multiple versions are registered" do
      it "returns the requested version" do
        test_weather = double(:test_weather)
        other_weather = double(:other_weather)
        Barometer::WeatherService.register(:test_weather, nil, test_weather)
        Barometer::WeatherService.register(:test_weather, :v1, other_weather)

        Barometer::WeatherService.source(:test_weather).should == test_weather
        Barometer::WeatherService.source(:test_weather, nil).should == test_weather
        Barometer::WeatherService.source(:test_weather, :v1).should == other_weather
      end
    end
  end

  describe ".measure" do
    let(:test_weather) { double(:test_weather) }
    let(:query) { double(:query) }
    let(:test_response) { Barometer::Response.new }

    before do
      test_weather.stub(:call).and_return(test_response)
      Barometer::WeatherService.register(:test_weather, test_weather)
    end

    it "calls the requested weather service" do
      test_weather.should_receive(:call)
      Barometer::WeatherService.measure(:test_weather, query)
    end

    it "calls the requested version of the weather service" do
      test_weather_v2 = double(:test_weather)
      Barometer::WeatherService.register(:test_weather, :v2, test_weather_v2)

      test_weather_v2.should_receive(:call).and_return(test_response)

      Barometer::WeatherService.measure(:test_weather, query, :version => :v2)
    end

    it "passes along query and options" do
      test_weather.should_receive(:call).with(query)
      Barometer::WeatherService.measure(:test_weather, query)
    end

    describe "timing information" do
      it "adds response_started_at" do
        response = Barometer::WeatherService.measure(:test_weather, query)
        response.response_started_at.should_not be_nil
        response.response_started_at.should be_a(::Time)
      end

      it "adds response_ended_at" do
        response = Barometer::WeatherService.measure(:test_weather, query)
        response.response_ended_at.should_not be_nil
        response.response_ended_at.should be_a(::Time)
      end
    end

    describe "source information" do
      it "adds the source" do
        response = Barometer::WeatherService.measure(:test_weather, query)
        response.source.should == :test_weather
      end
    end

    describe "error handling" do
      it "adds code 200 if no errors" do
        test_response.stub(:complete? => true)

        response = Barometer::WeatherService.measure(:test_weather, query)
        response.status_code.should == 200
      end

      it "adds code 204 if service has no data" do
        test_response.stub(:complete? => false)

        response = Barometer::WeatherService.measure(:test_weather, query)
        response.status_code.should == 204
      end

      it "adds code 401 if required key not provided" do
        test_weather.stub(:call).and_raise(Barometer::WeatherService::KeyRequired)

        response = Barometer::WeatherService.measure(:test_weather, query)
        response.status_code.should == 401
      end

      it "adds code 406 if query format unsupported" do
        test_weather.stub(:call).and_raise(Barometer::Query::ConversionNotPossible)

        response = Barometer::WeatherService.measure(:test_weather, query)
        response.status_code.should == 406
      end

      it "adds code 406 if query region unsupported" do
        test_weather.stub(:call).and_raise(Barometer::Query::UnsupportedRegion)

        response = Barometer::WeatherService.measure(:test_weather, query)
        response.status_code.should == 406
      end

      it "adds code 408 if service unavailable (timeout)" do
        test_weather.stub(:call).and_raise(Timeout::Error)

        response = Barometer::WeatherService.measure(:test_weather, query)
        response.status_code.should == 408
      end
    end
  end

  after do
    Barometer::WeatherService.services = @services_cache
  end
end
