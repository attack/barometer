require_relative '../spec_helper'

module Barometer::WeatherService
  describe WundergroundV1, vcr: {
    cassette_name: "WeatherService::WundergroundV1"
  } do

    it "auto-registers this weather service as :wunderground" do
      Barometer::WeatherService.source(:wunderground, :v1).should == WundergroundV1
    end

    describe ".call" do
      let(:converted_query) { Barometer::ConvertedQuery.new('Calgary,AB', :geocode, :metric) }
      let(:query) { build_query.tap{|q|q.stub(:convert! => converted_query)} }

      subject { WundergroundV1.call(query) }

      it "asks the query to convert to accepted formats" do
        query.should_receive(:convert!).with(:zipcode, :postalcode, :icao, :coordinates, :geocode)
        subject
      end

      it "includes the expected data" do
        subject.query.should == 'Calgary,AB'
        subject.format.should == :geocode
        subject.should be_metric

        should have_data(:current, :observed_at).as_format(:time)
        should have_data(:current, :stale_at).as_format(:time)

        should have_data(:current, :humidity).as_format(:float)
        should have_data(:current, :condition).as_format(:string)
        should have_data(:current, :icon).as_format(:string)
        should have_data(:current, :temperature).as_format(:temperature)
        should have_data(:current, :dew_point).as_format(:temperature)
        # should have_data(:current, :wind_chill).as_format(:temperature)
        # should have_data(:current, :heat_index).as_format(:optional_string)
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

        should have_data(:timezone, :code).as_format(/^M[DS]T$/i)
        should have_data(:timezone, :to_s).as_value('America/Edmonton')

        subject.forecast.size.should == 6
        should have_forecast(:starts_at).as_format(:time)
        should have_forecast(:ends_at).as_format(:time)

        subject.forecast[0].ends_at.to_i.should == (subject.forecast[0].starts_at + (60 * 60 * 24 - 1)).to_i
        should have_forecast(:pop).as_format(:float)
        should have_forecast(:icon).as_format(:string)
        should have_forecast(:high).as_format(:temperature)
        should have_forecast(:low).as_format(:temperature)
        should have_forecast(:sun, :rise).as_format(:time)
        should have_forecast(:sun, :set).as_format(:time)
      end
    end
  end
end
