require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Barometer

describe Barometer::WeatherService::Noaa, :vcr => {
  :cassette_name => "WeatherService::Noaa"
} do
  before(:each) do
    @accepted_formats = [:zipcode, :coordinates]
  end

  it "auto-registers this weather service as :noaa" do
    Barometer::WeatherService.source(:noaa).should == Barometer::WeatherService::Noaa
  end

  describe "the class methods" do
    it "defines accepted_formats" do
      WeatherService::Noaa._accepted_formats.should == @accepted_formats
    end

    it "defines source_name" do
      WeatherService::Noaa._source_name.should == :noaa
    end

    it "defines fetch_current" do
      WeatherService::Noaa.respond_to?("_fetch_current").should be_true
    end

    it "defines fetch_forecast" do
      WeatherService::Noaa.respond_to?("_fetch_forecast").should be_true
    end

    it "defines get_all" do
      WeatherService::Noaa.respond_to?("_fetch").should be_true
    end

    describe "acceptable countries" do
      before(:each) do
        @query = Barometer::Query.new("90210")
        @measurement = Barometer::Measurement.new
      end

      it "accepts nil" do
        @query.country_code = nil
        WeatherService::Noaa._supports_country?(@query).should be_true
      end

      it "accepts blank" do
        @query.country_code = ""
        WeatherService::Noaa._supports_country?(@query).should be_true
      end

      it "accepts US" do
        @query.country_code = "US"
        WeatherService::Noaa._supports_country?(@query).should be_true
      end

      it "rejects other" do
        @query.country_code = "CA"
        WeatherService::Noaa._supports_country?(@query).should be_false
      end
    end
  end

  describe "building the current data" do
    it "defines the build method" do
      WeatherService::Noaa.respond_to?("_build_current").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::Noaa._build_current }.should raise_error(ArgumentError)
      lambda { WeatherService::Noaa._build_current({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Barometer::CurrentMeasurement object" do
      current = WeatherService::Noaa._build_current({})
      current.is_a?(Measurement::Result).should be_true
    end
  end

  describe "building the forecast data" do
    it "defines the build method" do
      WeatherService::Noaa.respond_to?("_build_forecast").should be_true
    end

    it "requires Hash input" do
      lambda { WeatherService::Noaa._build_forecast }.should raise_error(ArgumentError)
      lambda { WeatherService::Noaa._build_forecast({}) }.should_not raise_error(ArgumentError)
    end

    it "returns Array object" do
      current = WeatherService::Noaa._build_forecast({})
      current.is_a?(Array).should be_true
    end
  end

  describe "when measuring" do
    before(:each) do
      @query = Barometer::Query.new("90210")
      @measurement = Barometer::Measurement.new
    end

    describe "all" do
      it "responds to _measure" do
        Barometer::WeatherService::Noaa.respond_to?("_measure").should be_true
      end

      it "requires a Barometer::Measurement object" do
        lambda { Barometer::WeatherService::Noaa._measure(nil, @query) }.should raise_error(ArgumentError)
        lambda { Barometer::WeatherService::Noaa._measure("invalid", @query) }.should raise_error(ArgumentError)

        lambda { Barometer::WeatherService::Noaa._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "requires a Barometer::Query query" do
        lambda { Barometer::WeatherService::Noaa._measure }.should raise_error(ArgumentError)
        lambda { Barometer::WeatherService::Noaa._measure(@measurement, 1) }.should raise_error(ArgumentError)

        lambda { Barometer::WeatherService::Noaa._measure(@measurement, @query) }.should_not raise_error(ArgumentError)
      end

      it "returns a Barometer::Measurement object" do
        result = Barometer::WeatherService::Noaa._measure(@measurement, @query)
        result.is_a?(Barometer::Measurement).should be_true
        result.current.is_a?(Barometer::Measurement::Result).should be_true
        result.forecast.is_a?(Barometer::Measurement::ResultArray).should be_true
      end
    end
  end

  describe "response" do
    let(:query) { Barometer::Query.new("90210") }

    subject do
      WeatherService::Noaa._measure(Barometer::Measurement.new, query)
    end

    it "has the expected data" do
      should measure(:current, :humidity).as_format(:number)
      should measure(:current, :condition).as_format(:string)
      should measure(:current, :icon).as_format(:string)
      should measure(:current, :temperature).as_format(:temperature)
      should measure(:current, :dew_point).as_format(:temperature)
      should measure(:current, :wind_chill).as_format(:temperature)
      should measure(:current, :wind).as_format(:wind)
      should measure(:current, :wind, :direction).as_format(:wind_direction)
      should measure(:current, :wind, :degrees).as_format(:number)
      should measure(:current, :pressure).as_format(:pressure)

      should measure(:station, :id).as_value("KSMO")
      should measure(:station, :name).as_value("Santa Monica Muni, CA")
      should measure(:station, :city).as_value("Santa Monica Muni")
      should measure(:station, :state_code).as_value("CA")
      should measure(:station, :country_code).as_value("US")
      should measure(:station, :latitude).as_value(34.03)
      should measure(:station, :longitude).as_value(-118.45)

      should measure(:location, :city).as_value("Santa Monica Muni")
      should measure(:location, :state_code).as_value("CA")
      should measure(:location, :country_code).as_value("US")

      subject.forecast.size.should == 7
      should forecast(:valid_start_date).as_format(:date)
      should forecast(:valid_end_date).as_format(:date)
      should forecast(:condition).as_format(:string)
      should forecast(:icon).as_format(:string)
      should forecast(:high).as_format(:temperature)
      should forecast(:low).as_format(:temperature)

      should measure(:measured_at).as_format(:datetime)
      should measure(:current, :current_at).as_format(:datetime)
      should measure(:timezone, :code).as_format(/^P[DS]T$/i)
    end
  end
end
