require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Barometer

describe Barometer::WeatherService::WeatherBug, :vcr => {
  :cassette_name => "WeatherService::WeatherBug"
} do
  before(:each) do
    @accepted_formats = [:short_zipcode, :coordinates]
  end

  describe "the class methods" do
    it "defines accepted_formats" do
      WeatherService::WeatherBug._accepted_formats.should == @accepted_formats
    end

    it "defines source_name" do
      WeatherService::WeatherBug._source_name.should == :weather_bug
    end

    it "defines fetch_current" do
      WeatherService::WeatherBug.respond_to?("_fetch_current").should be_true
    end

    it "defines fetch_forecast" do
      WeatherService::WeatherBug.respond_to?("_fetch_forecast").should be_true
    end

    it "defines _requires_keys?" do
      WeatherService::WeatherBug.respond_to?("_requires_keys?").should be_true
      WeatherService::WeatherBug._requires_keys?.should be_true
    end

    it "defines _has_keys?" do
      WeatherService::WeatherBug.respond_to?("_has_keys?").should be_true
      WeatherService::WeatherBug._has_keys?.should be_false
      WeatherService::WeatherBug.keys = { :code => WEATHERBUG_CODE }
      WeatherService::WeatherBug._has_keys?.should be_true
    end
  end

  describe "building the current data" do
    it "defines the build method" do
      WeatherService::WeatherBug.respond_to?("_build_current").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherBug._build_current }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherBug._build_current({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Measurement::Current object" do
      current = WeatherService::WeatherBug._build_current({})
      current.is_a?(Measurement::Result).should be_true
    end
  end

  describe "building the forecast data" do
    it "defines the build method" do
      WeatherService::WeatherBug.respond_to?("_build_forecast").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherBug._build_forecast }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherBug._build_forecast({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Array object" do
      current = WeatherService::WeatherBug._build_forecast({})
      current.is_a?(Array).should be_true
    end
  end

  describe "building the location data" do
    it "defines the build method" do
      WeatherService::WeatherBug.respond_to?("_build_location").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherBug._build_location }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherBug._build_location({}) }.should_not raise_error(ArgumentError)
    end

    it "requires Barometer::Geo input" do
      geo = Data::Geo.new({})
      lambda { WeatherService::WeatherBug._build_location({}, {}) }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherBug._build_location({}, geo) }.should_not raise_error(ArgumentError)
    end

    it "returns Barometer::Location object" do
      location = WeatherService::WeatherBug._build_location({})
      location.is_a?(Data::Location).should be_true
    end
  end

  describe "building the sun data" do
    it "defines the build method" do
      WeatherService::WeatherBug.respond_to?("_build_sun").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherBug._build_sun }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherBug._build_sun({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Barometer::Sun object" do
      sun = WeatherService::WeatherBug._build_sun({})
      sun.is_a?(Data::Sun).should be_true
    end
  end

  describe "builds other data" do
    it "defines _build_extra" do
      WeatherService::WeatherBug.respond_to?("_build_extra").should be_true
    end

    it "defines _parse_local_time" do
      WeatherService::WeatherBug.respond_to?("_parse_local_time").should be_true
    end

    it "defines _build_timezone" do
      WeatherService::WeatherBug.respond_to?("_build_timezone").should be_true
    end
  end

  describe "when measuring" do
    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
    end

    describe "all" do
      it "responds to _measure" do
        WeatherService::WeatherBug.respond_to?("_measure").should be_true
      end

      it "requires a Barometer::Measurement object" do
        lambda { WeatherService::WeatherBug._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { WeatherService::WeatherBug._measure("invalid", @query) }.should raise_error(ArgumentError)

        lambda { WeatherService::WeatherBug._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "requires a Barometer::Query query" do
        lambda { WeatherService::WeatherBug._measure }.should raise_error(ArgumentError)
        lambda { WeatherService::WeatherBug._measure(@measurement, 1) }.should raise_error(ArgumentError)

        lambda { WeatherService::WeatherBug._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "returns a Barometer::Measurement object" do
        result = WeatherService::WeatherBug._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Measurement::Result).should be_true
        result.forecast.is_a?(Measurement::ResultArray).should be_true
      end
    end
  end

  describe "response" do
    let(:query) { Barometer::Query.new("90210") }

    subject do
      WeatherService::WeatherBug.keys = { :code => WEATHERBUG_CODE }
      WeatherService::WeatherBug._measure(Barometer::Measurement.new, query)
    end

    it "has the expected data" do
      should measure(:current, :humidity).as_format(:number)
      should measure(:current, :condition).as_format(:optional_string)
      should measure(:current, :icon).as_format(:number)
      should measure(:current, :temperature).as_format(:temperature)
      should measure(:current, :dew_point).as_format(:temperature)
      should measure(:current, :wind_chill).as_format(:temperature)
      should measure(:current, :wind).as_format(:wind)
      should measure(:current, :wind, :direction).as_format(:wind_direction)
      should measure(:current, :pressure).as_format(:pressure)
      should measure(:current, :sun, :rise).as_format(:datetime)
      should measure(:current, :sun, :set).as_format(:datetime)

      should measure(:station, :id).as_value("LSNGN")
      should measure(:station, :name).as_value("Alexander Hamilton Senior HS")
      should measure(:station, :city).as_value("Los Angeles")
      should measure(:station, :state_code).as_value("CA")
      should measure(:station, :country).as_value("USA")
      should measure(:station, :zip_code).as_value("90034")
      should measure(:station, :latitude).as_value(34.0336112976074)
      should measure(:station, :longitude).as_value(-118.389999389648)

      should measure(:location, :city).as_value("Beverly Hills")
      should measure(:location, :state_code).as_value("CA")
      should measure(:location, :zip_code).as_value("90210")

      should measure(:measured_at).as_format(:datetime)
      should measure(:current, :current_at).as_format(:datetime)
      should measure(:timezone, :code).as_format(/^P[DS]T$/i)

      subject.forecast.size.should == 7
      should forecast(:date).as_format(:date)
      should forecast(:condition).as_format(:optional_string)
      should forecast(:icon).as_format(:number)
      should forecast(:high).as_format(:temperature)
      should forecast(:low).as_format(:temperature)
      should forecast(:sun, :rise).as_format(:datetime)
      should forecast(:sun, :set).as_format(:datetime)
    end
  end
end
