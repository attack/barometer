require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WeatherService::Noaa, :vcr => {
  :cassette_name => "WeatherService::Noaa"
} do

  it "auto-registers this weather service as :noaa" do
    Barometer::WeatherService.source(:noaa).should == Barometer::WeatherService::Noaa
  end

  describe ".call" do
    let(:query) { double(:query, :geo => nil, :add_conversion => nil) }
    let(:config) { {:metric => true} }

    subject { Barometer::WeatherService::Noaa.call(query, config) }

    before do
      query.stub(:convert!).and_return do |*formats|
        if formats.include?(:noaa_station_id)
          Barometer::ConvertedQuery.new("KSMO", :station_id)
        elsif formats.include?(:zipcode)
          Barometer::ConvertedQuery.new("90210", :zipcode)
        end
      end
    end

    it "asks the query to convert to accepted formats" do
      query.should_receive(:convert!).with(:zipcode, :coordinates)
      subject
    end

    it "adds a coordinate conversion to the query" do
      query.should_receive(:add_conversion).with(:coordinates, '34.10,-118.41')
      subject
    end

    it "includes the expected data" do
      subject.query.should == "90210"
      subject.format.should == :zipcode
      subject.metric.should be_true

      should have_data(:current, :observed_at).as_format(:time)
      should have_data(:current, :stale_at).as_format(:time)

      should have_data(:current, :humidity).as_format(:float)
      should have_data(:current, :condition).as_format(:string)
      should have_data(:current, :icon).as_format(:string)
      should have_data(:current, :temperature).as_format(:temperature)
      should have_data(:current, :wind_chill).as_format(:temperature)
      should have_data(:current, :dew_point).as_format(:temperature)
      should have_data(:current, :wind).as_format(:vector)
      should have_data(:current, :pressure).as_format(:pressure)
      should have_data(:current, :visibility).as_format(:distance)

      should have_data(:location, :name).as_value("Santa Monica Muni, CA")
      should have_data(:location, :city).as_value("Santa Monica Muni")
      should have_data(:location, :state_code).as_value("CA")
      should have_data(:location, :country_code).as_value("US")
      should have_data(:location, :latitude).as_value(34.10)
      should have_data(:location, :longitude).as_value(-118.41)

      should have_data(:station, :id).as_value("KSMO")
      should have_data(:station, :name).as_value("Santa Monica Muni, CA")
      should have_data(:station, :city).as_value("Santa Monica Muni")
      should have_data(:station, :state_code).as_value("CA")
      should have_data(:station, :country_code).as_value("US")
      should have_data(:station, :latitude).as_value(34.10)
      should have_data(:station, :longitude).as_value(-118.41)

      should have_data(:timezone, :code).as_format(/^P[DS]T$/i)

      subject.forecast.size.should == 14
      should have_forecast(:starts_at).as_format(:time)
      should have_forecast(:ends_at).as_format(:time)
      should have_forecast(:icon).as_format(:string)
      should have_forecast(:condition).as_format(:string)
      should have_forecast(:pop).as_format(:float)
      should have_forecast(:high).as_format(:temperature)
      should have_forecast(:low).as_format(:temperature)
    end
  end
end
