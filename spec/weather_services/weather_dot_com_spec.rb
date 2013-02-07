require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Barometer

describe Barometer::WeatherService::WeatherDotCom do
  use_vcr_cassette

  before(:each) do
    @accepted_formats = [:short_zipcode, :weather_id]
  end

  describe "the class methods" do
    it "defines accepted_formats" do
      WeatherService::WeatherDotCom._accepted_formats.should == @accepted_formats
    end

    it "defines source_name" do
      WeatherService::WeatherDotCom._source_name.should == :weather_dot_com
    end

    it "defines get_all" do
      WeatherService::WeatherDotCom.respond_to?("_fetch").should be_true
    end

    it "defines _requires_keys?" do
      WeatherService::WeatherDotCom.respond_to?("_requires_keys?").should be_true
      WeatherService::WeatherDotCom._requires_keys?.should be_true
    end

    it "defines _has_keys?" do
      WeatherService::WeatherDotCom.respond_to?("_has_keys?").should be_true
      WeatherService::WeatherDotCom._has_keys?.should be_false
      WeatherService::WeatherDotCom.keys = { :partner => WEATHER_PARTNER_KEY, :license => WEATHER_LICENSE_KEY }
      WeatherService::WeatherDotCom._has_keys?.should be_true
    end
  end

  describe "building the current data" do
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_current").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_current }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_current({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Measurement::Current object" do
      current = WeatherService::WeatherDotCom._build_current({})
      current.is_a?(Measurement::Result).should be_true
    end
  end

  describe "building the forecast data" do
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_forecast").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_forecast }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_forecast({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Array object" do
      current = WeatherService::WeatherDotCom._build_forecast({})
      current.is_a?(Array).should be_true
    end
  end

  describe "building the location data" do
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_location").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_location }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_location({}) }.should_not raise_error(ArgumentError)
    end

    it "requires Barometer::Geo input" do
      geo = Data::Geo.new({})
      lambda { WeatherService::WeatherDotCom._build_location({}, {}) }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_location({}, geo) }.should_not raise_error(ArgumentError)
    end

    it "returns Barometer::Location object" do
      location = WeatherService::WeatherDotCom._build_location({})
      location.is_a?(Data::Location).should be_true
    end
  end

  describe "building the sun data" do
    it "defines the build method" do
      WeatherService::WeatherDotCom.respond_to?("_build_sun").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::WeatherDotCom._build_sun }.should raise_error(ArgumentError)
      lambda { WeatherService::WeatherDotCom._build_sun({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Barometer::Sun object" do
      sun = WeatherService::WeatherDotCom._build_sun({})
      sun.is_a?(Data::Sun).should be_true
    end
  end

  describe "when measuring" do
    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
    end

    describe "all" do
      it "responds to _measure" do
        WeatherService::WeatherDotCom.respond_to?("_measure").should be_true
      end

      it "requires a Barometer::Measurement object" do
        lambda { WeatherService::WeatherDotCom._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { WeatherService::WeatherDotCom._measure("invalid", @query) }.should raise_error(ArgumentError)

        lambda { WeatherService::WeatherDotCom._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "requires a Barometer::Query query" do
        lambda { WeatherService::WeatherDotCom._measure }.should raise_error(ArgumentError)
        lambda { WeatherService::WeatherDotCom._measure(@measurement, 1) }.should raise_error(ArgumentError)

        lambda { WeatherService::WeatherDotCom._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "returns a Barometer::Measurement object" do
        result = WeatherService::WeatherDotCom._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Measurement::Result).should be_true
        result.forecast.is_a?(Measurement::ResultArray).should be_true
      end
    end
  end

  describe "overall data correctness" do
    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
    end

    it "should correctly build the data" do
      result = WeatherService::WeatherDotCom._measure(@measurement, @query)

      # build current
      @measurement.current.humidity.to_s.should match(/^\d{1,2}$/i)
      @measurement.current.icon.should match(/^\d{1,3}$/i)
      @measurement.current.condition.should match(/^[\w ]+$/i)
      @measurement.current.temperature.to_s.should match(/^\d{1,3}[ ]?[cfCF]?$/i)
      @measurement.current.dew_point.to_s.should match(/^\d{1,3}[ ]?[cfCF]?$/i)
      @measurement.current.wind_chill.to_s.should match(/^\d{1,3}[ ]?[cfCF]?$/i)
      @measurement.current.wind.to_s.should match(/^\d{1,3}[ ]?[a-zA-Z]{0,3}$/i)
      @measurement.current.wind.degrees.to_s.should match(/^\d{1,3}\.?\d{0,2}$/i)
      @measurement.current.wind.direction.should match(/^[neswNESW]{0,3}$/i)
      @measurement.current.pressure.to_s.should match(/^\d{1,4}[ ]?[a-zA-Z]{0,3}$/i)
      @measurement.current.visibility.to_s.should match(/^\d{1,3}[ ]?[a-zA-Z]{0,2}$/i)

      # build sun
      @measurement.current.sun.rise.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)
      @measurement.current.sun.set.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)

      # builds location
      @measurement.location.name.should == "Beverly Hills, CA (90210)"
      @measurement.location.latitude.to_f.should == 34.10
      @measurement.location.longitude.to_f.should == -118.41

      # builds forecasts
      @measurement.forecast.size.should == 10

      # day
      @measurement.forecast[0].valid_start_date.to_s.should match(/^\d{1,4}-\d{1,2}-\d{1,2}$/i)
      @measurement.forecast[0].valid_end_date.to_s.should match(/^\d{1,4}-\d{1,2}-\d{1,2}$/i)
      @measurement.forecast[0].condition.should == "N/A"
      @measurement.forecast[0].icon.should match(/^\d{1,3}$/i)
      @measurement.forecast[0].high.should be_nil
      @measurement.forecast[0].low.to_s.should match(/^\d{1,3}[ ]?[cfCF]?$/i)
      @measurement.forecast[0].pop.to_s.should match(/^\d{1,3}$/i)
      @measurement.forecast[0].humidity.to_s.should match(/^\d{1,3}$/i)

      @measurement.forecast[0].wind.should be_nil
      @measurement.forecast[0].wind.to_i.should be_nil
      @measurement.forecast[0].wind.degrees.to_i.should == 0
      @measurement.forecast[0].wind.direction.should == "N/A"

      @measurement.forecast[0].sun.rise.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)
      @measurement.forecast[0].sun.set.to_s.should match(/^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i)

      # night
      @measurement.forecast[1].should_not be_nil
      @measurement.forecast[1].valid_start_date.to_s.should match(/^\d{1,4}-\d{1,2}-\d{1,2}$/i)
      @measurement.forecast[1].valid_end_date.to_s.should match(/^\d{1,4}-\d{1,2}-\d{1,2}$/i)
      @measurement.forecast[1].condition.should match(/^[\w ]+$/i)
      @measurement.forecast[1].icon.should match(/^\d{1,3}$/i)
      @measurement.forecast[1].pop.to_s.should match(/^\d{1,3}$/i)
      @measurement.forecast[1].humidity.to_s.should match(/^\d{1,3}$/i)

      @measurement.forecast[1].wind.should_not be_nil
      @measurement.forecast[1].wind.to_s.should match(/^\d{1,3}[ ]?[a-zA-Z]{0,3}$/i)
      @measurement.forecast[1].wind.degrees.to_s.should match(/^\d{1,3}\.?\d{0,2}$/i)
      @measurement.forecast[1].wind.direction.should match(/^[neswNESW]{0,3}$/i)
    end
  end
end
