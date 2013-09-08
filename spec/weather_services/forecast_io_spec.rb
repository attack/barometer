require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::WeatherService::ForecastIo, :vcr => {
  :cassette_name => "WeatherService::ForecastIo"
} do

  it "auto-registers this weather service as :forecast_io" do
    Barometer::WeatherService.source(:forecast_io).should == Barometer::WeatherService::ForecastIo
  end

  describe ".call" do
    context "when no keys provided" do
      let(:query) { build_query }

      it "raises error" do
        expect {
          Barometer::WeatherService::ForecastIo.call(query)
        }.to raise_error(Barometer::WeatherService::KeyRequired)
      end
    end

    context "when keys are provided" do
      let(:converted_query) { Barometer::ConvertedQuery.new('42.7243,-73.6927', :coordinates, :metric) }
      let(:query) { build_query.tap{|q|q.stub(:convert! => converted_query)} }
      let(:config) { {:keys => {:api => FORECAST_IO_APIKEY}} }

      subject { Barometer::WeatherService::ForecastIo.call(query, config) }

      it "asks the query to convert to accepted formats" do
        query.should_receive(:convert!).with(:coordinates)
        subject
      end

      it "includes the expected data" do
        subject.query.should == '42.7243,-73.6927'
        subject.format.should == :coordinates
        subject.metric.should be_true

        should have_data(:current, :observed_at).as_format(:time)
        # should have_data(:current, :stale_at).as_format(:time)

        should have_data(:current, :humidity).as_format(:float)
        should have_data(:current, :condition).as_format(:string)
        should have_data(:current, :icon).as_format(:string)
        should have_data(:current, :temperature).as_format(:temperature)
        should have_data(:current, :dew_point).as_format(:temperature)
        should have_data(:current, :wind).as_format(:vector)
        should have_data(:current, :pressure).as_format(:pressure)
        should have_data(:current, :visibility).as_format(:distance)
        # should have_data(:current, :sun, :rise).as_format(:time)
        # should have_data(:current, :sun, :set).as_format(:time)

        should have_data(:location, :latitude).as_value(42.7243)
        should have_data(:location, :longitude).as_value(-73.6927)

        should have_data(:timezone, :to_s).as_value('America/New_York')
        should have_data(:timezone, :code).as_format(/^E[DS]T$/i)

        subject.forecast.size.should == 8
        should have_forecast(:starts_at).as_format(:time)
        should have_forecast(:ends_at).as_format(:time)
        should have_forecast(:icon).as_format(:string)
        should have_forecast(:condition).as_format(:string)
        should have_forecast(:high).as_format(:temperature)
        should have_forecast(:low).as_format(:temperature)
        should have_forecast(:sun, :rise).as_format(:time)
        should have_forecast(:sun, :set).as_format(:time)
      end
    end
  end
end
