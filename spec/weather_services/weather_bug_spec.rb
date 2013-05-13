require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WeatherService::WeatherBug, :vcr => {
  :cassette_name => "WeatherService::WeatherBug"
} do

  it "auto-registers this weather service as :weather_bug" do
    Barometer::WeatherService.source(:weather_bug).should == Barometer::WeatherService::WeatherBug
  end

  describe ".call" do
    context "when no keys provided" do
      it "raises error" do
        expect {
          Barometer::WeatherService::WeatherBug.call(nil)
        }.to raise_error(Barometer::WeatherService::KeyRequired)
      end
    end

    context "when keys are provided" do
      let(:converted_query) { Barometer::ConvertedQuery.new("90210", :short_zipcode) }
      let(:query) { double(:query, :convert! => converted_query, :geo => nil) }
      let(:config) { {:keys => {:code => WEATHERBUG_CODE}, :metric => true} }

      subject { Barometer::WeatherService::WeatherBug.call(query, config) }

      it "asks the query to convert to accepted formats" do
        query.should_receive(:convert!).with(:short_zipcode, :coordinates)
        subject
      end

      it "includes the expected data" do
        subject.query.should == "90210"
        subject.format.should == :short_zipcode
        subject.metric.should be_true

        should have_data(:current, :observed_at).as_format(:time)
        # specifics about when?
        should have_data(:current, :stale_at).as_format(:time)

        should have_data(:current, :humidity).as_format(:float)
        should have_data(:current, :condition).as_format(:string)
        should have_data(:current, :icon).as_format(:number)
        should have_data(:current, :temperature).as_format(:temperature)
        should have_data(:current, :dew_point).as_format(:temperature)
        should have_data(:current, :wind_chill).as_format(:temperature)
        should have_data(:current, :wind).as_format(:vector)
        should have_data(:current, :pressure).as_format(:pressure)
        should have_data(:current, :sun, :rise).as_format(:time)
        should have_data(:current, :sun, :set).as_format(:time)

        should have_data(:station, :id).as_value("LSNGN")
        should have_data(:station, :name).as_value("Alexander Hamilton Senior HS")
        should have_data(:station, :city).as_value("Los Angeles")
        should have_data(:station, :state_code).as_value("CA")
        should have_data(:station, :country).as_value("USA")
        should have_data(:station, :zip_code).as_value("90034")
        should have_data(:station, :latitude).as_value(34.0336112976074)
        should have_data(:station, :longitude).as_value(-118.389999389648)

        should have_data(:location, :city).as_value("Beverly Hills")
        should have_data(:location, :state_code).as_value("CA")
        should have_data(:location, :zip_code).as_value("90210")

        should have_data(:timezone, :code).as_format(/^P[DS]T$/i)

        subject.forecast.size.should == 7
        should have_forecast(:starts_at).as_format(:time)
        should have_forecast(:ends_at).as_format(:time)
        should have_forecast(:condition).as_format(:string)
        should have_forecast(:icon).as_format(:number)
        should have_forecast(:high).as_format(:temperature)
        should have_forecast(:low).as_format(:temperature)
      end
    end
  end
end
