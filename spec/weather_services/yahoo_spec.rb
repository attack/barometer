require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Barometer

describe Barometer::WeatherService::Yahoo, :vcr => {
  :cassette_name => "WeatherService::Yahoo"
} do
  before(:each) do
    @accepted_formats = [:zipcode, :weather_id, :woe_id]
  end

  describe "the class methods" do
    it "defines accepted_formats" do
      WeatherService::Yahoo._accepted_formats.should == @accepted_formats
    end

    it "defines source_name" do
      WeatherService::Yahoo._source_name.should == :yahoo
    end

    it "defines get_all" do
      WeatherService::Yahoo.respond_to?("_fetch").should be_true
    end
  end

  describe "building the current data" do
    it "defines the build method" do
      WeatherService::Yahoo.respond_to?("_build_current").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::Yahoo._build_current }.should raise_error(ArgumentError)
      lambda { WeatherService::Yahoo._build_current({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Barometer::CurrentMeasurement object" do
      current = WeatherService::Yahoo._build_current({})
      current.is_a?(Measurement::Result).should be_true
    end
  end

  describe "building the forecast data" do
    it "defines the build method" do
      WeatherService::Yahoo.respond_to?("_build_forecast").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::Yahoo._build_forecast }.should raise_error(ArgumentError)
      lambda { WeatherService::Yahoo._build_forecast({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Array object" do
      current = WeatherService::Yahoo._build_forecast({})
      current.is_a?(Array).should be_true
    end
  end

  describe "building the location data" do
    it "defines the build method" do
      WeatherService::Yahoo.respond_to?("_build_location").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::Yahoo._build_location }.should raise_error(ArgumentError)
      lambda { WeatherService::Yahoo._build_location({}) }.should_not raise_error(ArgumentError)
    end

    it "requires Barometer::Geo input" do
      geo = Data::Geo.new({})
      lambda { WeatherService::Yahoo._build_location({}, {}) }.should raise_error(ArgumentError)
      lambda { WeatherService::Yahoo._build_location({}, geo) }.should_not raise_error(ArgumentError)
    end

    it "returns Barometer::Location object" do
      location = WeatherService::Yahoo._build_location({})
      location.is_a?(Data::Location).should be_true
    end
  end

  describe "when measuring" do
    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
    end

    describe "all" do
      it "responds to _measure" do
        WeatherService::Yahoo.respond_to?("_measure").should be_true
      end

      it "requires a Barometer::Measurement object" do
        lambda { WeatherService::Yahoo._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { WeatherService::Yahoo._measure("invlaid", @query) }.should raise_error(ArgumentError)

        lambda { WeatherService::Yahoo._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "requires a Barometer::Query query" do
        lambda { WeatherService::Yahoo._measure }.should raise_error(ArgumentError)
        lambda { WeatherService::Yahoo._measure(@measurement, 1) }.should raise_error(ArgumentError)

        lambda { WeatherService::Yahoo._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "returns a Barometer::Measurement object" do
        result = WeatherService::Yahoo._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Measurement::Result).should be_true
        result.forecast.is_a?(Array).should be_true
      end
    end
  end

  describe "overall data correctness" do
    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
    end

    it "should correctly build the data" do
      result = WeatherService::Yahoo._measure(@measurement, @query)

      # build current
      @measurement.current.sun.rise.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)
      @measurement.current.sun.set.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)

      # builds location
      @measurement.location.city.should == "Beverly Hills"

      # builds forecasts
      @measurement.forecast.size.should == 2

      @measurement.forecast[0].condition.should match(/^[\w ]+$/i)
      @measurement.forecast[0].icon.to_s.should match(/^\d{1,3}$/i)
      @measurement.forecast[0].sun.rise.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)
      @measurement.forecast[0].sun.set.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)

      @measurement.forecast[1].condition.should match(/^[\w ]+$/i)
      @measurement.forecast[1].icon.to_s.should match(/^\d{1,3}$/i)
      @measurement.forecast[1].sun.rise.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)
      @measurement.forecast[1].sun.set.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)
    end
  end
end
