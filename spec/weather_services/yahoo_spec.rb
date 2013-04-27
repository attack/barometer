require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Barometer

describe Barometer::WeatherService::Yahoo, :vcr => {
  :cassette_name => "WeatherService::Yahoo"
} do

  it "auto-registers this weather service as :yahoo" do
    Barometer::WeatherService.source(:yahoo).should == Barometer::WeatherService::Yahoo
  end

  describe ".call" do
    let(:converted_query) { Barometer::ConvertedQuery.new("90210", :zipcode) }
    let(:query) { double(:query, :convert! => converted_query, :geo => nil) }
    let(:config) { {:metric => true} }

    subject { WeatherService::Yahoo.call(query, config) }

    it "asks the query to convert to accepted formats" do
      query.should_receive(:convert!).with(:zipcode, :weather_id, :woe_id)
      subject
    end

    it "includes the expected data" do
      should be_a Barometer::Measurement
      subject.query.should == "90210"
      subject.format.should == :zipcode
      subject.metric.should be_true

      should have_data(:current, :observed_at).as_format(:time)
      should have_data(:current, :stale_at).as_format(:time)

      should have_data(:current, :humidity).as_format(:float)
      should have_data(:current, :condition).as_format(:string)
      should have_data(:current, :icon).as_format(:number)
      should have_data(:current, :temperature).as_format(:temperature)
      should have_data(:current, :wind_chill).as_format(:temperature)
      should have_data(:current, :wind).as_format(:vector)
      should have_data(:current, :pressure).as_format(:pressure)
      should have_data(:current, :visibility).as_format(:distance)
      should have_data(:current, :sun, :rise).as_format(:time)
      should have_data(:current, :sun, :set).as_format(:time)

      should have_data(:location, :city).as_value("Beverly Hills")
      should have_data(:location, :state_code).as_value("CA")
      should have_data(:location, :country_code).as_value("US")
      should have_data(:location, :latitude).as_value(34.08)
      should have_data(:location, :longitude).as_value(-118.4)

      should have_data(:timezone, :code).as_format(/^P[DS]T$/i)

      subject.forecast.size.should == 2
      should have_forecast(:starts_at).as_format(:time)
      should have_forecast(:ends_at).as_format(:time)
      should have_forecast(:icon).as_format(:number)
      should have_forecast(:condition).as_format(:string)
      should have_forecast(:high).as_format(:temperature)
      should have_forecast(:low).as_format(:temperature)
      should have_forecast(:sun, :rise).as_format(:time)
      should have_forecast(:sun, :set).as_format(:time)
    end

    context "when the query already has geo data" do
      let(:geo) do
        double(:geo,
          :locality => "locality",
          :region => "region",
          :country => "country",
          :country_code => "country_code",
          :latitude => "latitude",
          :longitude => "longitude"
        )
      end

      before { query.stub(:geo => geo) }

      it "uses the query geo data for 'location'" do
        should have_data(:location, :city).as_value("locality")
        should have_data(:location, :state_code).as_value("region")
        should have_data(:location, :country).as_value("country")
        should have_data(:location, :country_code).as_value("country_code")
        should have_data(:location, :latitude).as_value("latitude")
        should have_data(:location, :longitude).as_value("longitude")
      end
    end
  end
end
