require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Barometer

describe Barometer::WeatherService::Wunderground, :vcr => {
  :cassette_name => "WeatherService::Wunderground"
} do

  it "auto-registers this weather service as :wunderground" do
    Barometer::WeatherService.source(:wunderground).should == Barometer::WeatherService::Wunderground
  end

  describe ".call" do
    context "when the query format is not accepted" do
      let(:query) { double(:query, :convert! => nil) }

      it "asks the query to convert to accepted formats" do
        query.should_receive(:convert!).with([:zipcode, :postalcode, :icao, :coordinates, :geocode])
        begin
          WeatherService::Wunderground.call(query)
        rescue
        end
      end

      it "raises error" do
        expect {
          WeatherService::Wunderground.call(query)
        }.to raise_error(Barometer::Query::ConversionNotPossible)
      end
    end

    context "when the query format is accepted" do
      let(:converted_query) { Barometer::Query.new("Calgary,AB") }
      let(:query) { double(:query, :convert! => converted_query) }

      subject { WeatherService::Wunderground.call(query) }

      it "includes the expected data" do
        should be_a Barometer::Measurement
        subject.query.should == "Calgary,AB"
        subject.format.should == :geocode

        should have_data(:current, :starts_at).as_format(:datetime)
        should have_data(:current, :humidity).as_format(:float)
        should have_data(:current, :condition).as_format(:string)
        should have_data(:current, :icon).as_format(:string)
        should have_data(:current, :temperature).as_format(:temperature)
        should have_data(:current, :dew_point).as_format(:temperature)
        should have_data(:current, :wind_chill).as_format(:temperature)
        should have_data(:current, :heat_index).as_format(:optional_string)
        should have_data(:current, :wind).as_format(:vector)
        should have_data(:current, :visibility).as_format(:distance)
        should have_data(:current, :pressure).as_format(:pressure)
        should have_data(:current, :sun, :rise).as_format(:time)
        should have_data(:current, :sun, :set).as_format(:time)

        should have_data(:station, :id).as_value("CYYC")
        should have_data(:station, :name).as_value("Calgary,")
        should have_data(:station, :city).as_value("Calgary")
        should have_data(:station, :state_code).as_format(:optional_string)
        should have_data(:station, :country_code).as_value("CA")
        should have_data(:station, :latitude).as_value(51.11999893)
        should have_data(:station, :longitude).as_value(-114.01999664)

        should have_data(:location, :name).as_value("Calgary, Alberta")
        should have_data(:location, :city).as_value("Calgary")
        should have_data(:location, :state_code).as_value("AB")
        should have_data(:location, :state_name).as_value("Alberta")
        should have_data(:location, :zip_code).as_value("00000")
        should have_data(:location, :country_code).as_value("CA")
        should have_data(:location, :latitude).as_value(51.11999893)
        should have_data(:location, :longitude).as_value(-114.01999664)

        should have_data(:published_at).as_format(:datetime)
        should have_data(:timezone, :code).as_format(/^M[DS]T$/i)
        should have_data(:timezone, :zone_full).as_value('America/Edmonton')
        should have_data(:timezone, :current).as_value('America/Edmonton')

        subject.forecast.size.should == 6
        should have_forecast(:starts_at).as_format(:datetime)
        should have_forecast(:ends_at).as_format(:datetime)
        should have_forecast(:pop).as_format(:float)
        should have_forecast(:icon).as_format(:string)
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

        before { converted_query.stub(:geo => geo) }

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
end
