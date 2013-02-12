require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WeatherService, :vcr => {
  :cassette_name => "WeatherService"
} do
  before(:each) do
    query_term = "Calgary,AB"
    @query = Barometer::Query.new(query_term)
    @service = Barometer::WeatherService.source(:wunderground)
    @time = Time.now
  end

  describe ".register" do
    before do
      @services_cache = Barometer::WeatherService.services
      Barometer::WeatherService.services = {}
    end

    after do
      Barometer::WeatherService.services = @services_cache
    end

    it "adds the weather service to the list of available services" do
      expect {
        Barometer::WeatherService.register(:test_weather, double(:weather_service))
      }.to change { Barometer::WeatherService.services.count }.by(1)
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

  describe "when initialized" do
    before(:each) do
      @service = Barometer::WeatherService.new
      @measurement = Barometer::Measurement.new
      @query = Barometer::Query.new("test")
    end

    it "defaults _meets_requirements?" do
      Barometer::WeatherService.send("_meets_requirements?").should be_true
    end

    it "stubs _source_name" do
      lambda { Barometer::WeatherService.send("_source_name") }.should raise_error(NotImplementedError)
    end

    it "stubs _accepted_formats" do
      lambda { Barometer::WeatherService.send("_accepted_formats") }.should raise_error(NotImplementedError)
    end

    it "stubs _measure" do
      Barometer::WeatherService._measure(@measurement,@query,true).is_a?(Barometer::Measurement).should be_true
    end

    it "stubs _build_extra" do
      Barometer::WeatherService._build_extra.should be_nil
    end

    it "stubs _fetch" do
      Barometer::WeatherService._fetch.should be_nil
    end

    it "stubs _build_current" do
      Barometer::WeatherService._build_current.should be_nil
    end

    it "stubs _build_forecast" do
      Barometer::WeatherService._build_forecast.should be_nil
    end

    it "stubs _build_location" do
      Barometer::WeatherService._build_location.should be_nil
    end

    it "stubs _build_sun" do
      Barometer::WeatherService._build_sun.should be_nil
    end

    it "stubs _build_links" do
      Barometer::WeatherService._build_links.should == {}
    end

    it "defaults _supports_country?" do
      Barometer::WeatherService._supports_country?.should be_true
    end

    it "defaults _requires_keys?" do
      Barometer::WeatherService._requires_keys?.should be_false
    end

    it "defaults _has_keys?" do
      lambda { Barometer::WeatherService._has_keys? }.should raise_error(NotImplementedError)
    end
  end

  describe "when measuring," do
    it "responds to measure" do
      Barometer::WeatherService.respond_to?("measure").should be_true
    end

    # since Barometer::WeatherService defines the measure method, you could actually just
    # call Barometer::WeatherService.measure ... but this will not invoke a specific
    # weather API driver.  Make sure this usage raises an error.
    it "requires an actuall driver" do
      lambda { Barometer::WeatherService.measure(@query) }.should raise_error(NotImplementedError)
    end

    it "requires a Barometer::Query object" do
      lambda { Barometer::WeatherService.measure("invalid") }.should raise_error(ArgumentError)
      @query.is_a?(Barometer::Query).should be_true
      lambda { Barometer::WeatherService.measure(@query) }.should_not raise_error(ArgumentError)
    end

    it "returns a Barometer::Measurement object" do
      @service.measure(@query).is_a?(Barometer::Measurement).should be_true
    end

    it "returns current and future" do
      measurement = @service.measure(@query)
      measurement.current.is_a?(Barometer::Measurement::Result).should be_true
      measurement.forecast.is_a?(Array).should be_true
    end
  end
end
