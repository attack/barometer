require_relative '../spec_helper'

module Barometer::WeatherService
  RSpec.describe WundergroundV1, vcr: {
    cassette_name: 'WeatherService::WundergroundV1'
  } do

    it "auto-registers this weather service as :wunderground" do
      expect(Barometer::WeatherService.source(:wunderground, :v1)).to eq WundergroundV1
    end

    describe ".call" do
      let(:converted_query) { Barometer::ConvertedQuery.new('Calgary,AB', :geocode, :metric) }
      let(:query) { build_query.tap{|q| allow(q).to receive(:convert!).and_return(converted_query)} }

      it "asks the query to convert to accepted formats" do
        allow(query).to receive(:convert!).and_return(converted_query)

        WundergroundV1.call(query)

        expect(query).to have_received(:convert!).
          with(:zipcode, :postalcode, :icao, :coordinates, :geocode).
          at_least(:once)
      end

      it "includes the expected data" do
        response = WundergroundV1.call(query)

        expect(response.query).to eq 'Calgary,AB'
        expect(response.format).to eq :geocode
        expect(response).to be_metric

        expect(response).to have_data(:current, :observed_at).as_format(:time)
        expect(response).to have_data(:current, :stale_at).as_format(:time)

        expect(response).to have_data(:current, :humidity).as_format(:float)
        expect(response).to have_data(:current, :condition).as_format(:string)
        expect(response).to have_data(:current, :icon).as_format(:string)
        expect(response).to have_data(:current, :temperature).as_format(:temperature)
        expect(response).to have_data(:current, :dew_point).as_format(:temperature)
        # expect(response).to have_data(:current, :wind_chill).as_format(:temperature)
        # expect(response).to have_data(:current, :heat_index).as_format(:optional_string)
        expect(response).to have_data(:current, :wind).as_format(:vector)
        expect(response).to have_data(:current, :visibility).as_format(:distance)
        expect(response).to have_data(:current, :pressure).as_format(:pressure)
        expect(response).to have_data(:current, :sun, :rise).as_format(:time)
        expect(response).to have_data(:current, :sun, :set).as_format(:time)

        expect(response).to have_data(:station, :id).as_value("CYYC")
        expect(response).to have_data(:station, :name).as_value("Calgary,")
        expect(response).to have_data(:station, :city).as_value("Calgary")
        expect(response).to have_data(:station, :state_code).as_format(:optional_string)
        expect(response).to have_data(:station, :country_code).as_value("CA")
        expect(response).to have_data(:station, :latitude).as_value(51.11999893)
        expect(response).to have_data(:station, :longitude).as_value(-114.01999664)

        expect(response).to have_data(:location, :name).as_value("Calgary, Alberta")
        expect(response).to have_data(:location, :city).as_value("Calgary")
        expect(response).to have_data(:location, :state_code).as_value("AB")
        expect(response).to have_data(:location, :state_name).as_value("Alberta")
        expect(response).to have_data(:location, :zip_code).as_value("00000")
        expect(response).to have_data(:location, :country_code).as_value("CA")
        expect(response).to have_data(:location, :latitude).as_value(51.04999924)
        expect(response).to have_data(:location, :longitude).as_value(-114.05999756)

        expect(response).to have_data(:timezone, :code).as_format(/^M[DS]T$/i)
        expect(response).to have_data(:timezone, :to_s).as_value('America/Edmonton')

        expect(response.forecast.size).to eq 6
        expect(response).to have_forecast(:starts_at).as_format(:time)
        expect(response).to have_forecast(:ends_at).as_format(:time)

        expect(response.forecast[0].ends_at.to_i).to eq (response.forecast[0].starts_at + (60 * 60 * 24 - 1)).to_i
        expect(response).to have_forecast(:pop).as_format(:float)
        expect(response).to have_forecast(:icon).as_format(:string)
        expect(response).to have_forecast(:high).as_format(:temperature)
        expect(response).to have_forecast(:low).as_format(:temperature)
        expect(response).to have_forecast(:sun, :rise).as_format(:time)
        expect(response).to have_forecast(:sun, :set).as_format(:time)
      end
    end
  end
end
