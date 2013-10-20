require 'spec_helper'

module Barometer
  describe Weather do
    def fake_response(args)
      success = args.delete(:success?)
      weight = args.delete(:weight) || 1

      double(:response,
        success?: success.nil? ? true : success,
        weight: weight,
        current: double(:current, args)
      )
    end

    let(:weather) { Weather.new }

    describe ".new" do
      specify { expect( weather.responses ).to be_empty }
    end

    describe "#source" do
      let(:bar_response) { double(:response, source: :bar) }
      let(:foo_response) { double(:response, source: :foo) }

      before { weather.responses = [foo_response, bar_response] }

      it "returns the response for the specified source" do
        expect( weather.source(:foo) ).to eq foo_response
      end

      it "returns nil when nothing is found" do
        expect( weather.source(:baz) ).to be_nil
      end
    end

    describe "#success?" do
      it "returns true when a response is successful" do
        response_one = double(:response, success?: false)
        response_two = double(:response, success?: true)
        weather.responses = [response_one, response_two]
        expect( weather ).to be_success
      end

      it "returns false when no responses are successful" do
        response_one = double(:response, success?: false)
        response_two = double(:response, success?: false)
        weather.responses = [response_one, response_two]
        expect( weather ).not_to be_success
      end
    end

    describe "#current" do
      it "returns the current response for the first successful response" do
        current_two = double(:current)
        response_one = double(:response, success?: false)
        response_two = double(:response, success?: true, current: current_two)
        weather.responses = [response_one, response_two]

        expect( weather.current ).to eq current_two
      end
    end

    describe "#forecast" do
      it "returns the forecast response for the first successful response" do
        forecast_two = double(:forecast)
        response_one = double(:response, success?: false)
        response_two = double(:response, success?: true, forecast: forecast_two)
        weather.responses = [response_one, response_two]

        expect( weather.forecast ).to eq forecast_two
      end
    end

    describe "#today" do
      it "returns the first forecast response for the first successful response" do
        today = double(:forecast)
        tommorrow = double(:forecast)
        response_one = double(:response, success?: false)
        response_two = double(:response, success?: true, forecast: [today, tommorrow])
        weather.responses = [response_one, response_two]

        expect( weather.today ).to eq today
      end
    end

    describe "#tomorrow" do
      it "returns the second forecast response for the first successful response" do
        today = double(:forecast)
        tommorrow = double(:forecast)
        response_one = double(:response, success?: false)
        response_two = double(:response, success?: true, forecast: [today, tommorrow])
        weather.responses = [response_one, response_two]

        expect( weather.tomorrow ).to eq tommorrow
      end
    end

    describe "#for" do
      it "delegates to the first successful response" do
        response_one = double(:response, success?: false, for: nil)
        response_two = double(:response, success?: true, for: nil)
        weather.responses = [response_one, response_two]

        query = build_query
        weather.for(query)

        expect( response_two ).to have_received(:for).with(query)
      end
    end

    describe "#temperature" do
      let(:response_one) { fake_response(temperature: Data::Temperature.new(:metric, 20)) }
      let(:response_two) { fake_response(temperature: Data::Temperature.new(:metric, 30)) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average temeprature" do
        expect( weather.temperature ).to eq Data::Temperature.new(:metric, 25.0)
      end

      it "returns nil when there is no valid data" do
        response_one.stub(success?: false)
        response_two.stub(success?: false)
        expect( weather.temperature ).to be_nil
      end

      it "excludes unsuccessful responses" do
        response_three = fake_response(success?: false, temperature: Data::Temperature.new(:metric, 10))
        weather.responses << response_three
        expect( weather.temperature ).to eq Data::Temperature.new(:metric, 25.0)
      end

      it "excludes nil values" do
        response_three = fake_response(temperature: nil)
        weather.responses << response_three
        expect( weather.temperature ).to eq Data::Temperature.new(:metric, 25.0)
      end

      it "returns a weighted average temeprature" do
        response_one.stub(weight: 3)
        response_two.stub(weight: 1)
        expect( weather.temperature ).to eq Data::Temperature.new(:metric, 22.5)
      end

      it "respects response units" do
        response_two.current.stub(temperature: Data::Temperature.new(:imperial, 68.0))
        expect( weather.temperature.to_f ).to eq 20.0
      end

      it "respects weather units" do
        weather = Weather.new(:imperial)
        weather.responses = [response_one, response_two]

        expect( weather.temperature.to_f ).to eq 77.0
      end
    end

    describe "#humidity" do
      let(:response_one) { fake_response(humidity: 20.0) }
      let(:response_two) { fake_response(humidity: 30.0) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average humidity" do
        expect( weather.humidity ).to eq 25.0
      end

      it "returns nil when there is no valid data" do
        response_one.stub(success?: false)
        response_two.stub(success?: false)
        expect( weather.humidity ).to be_nil
      end

      it "excludes unsuccessful responses" do
        response_three = fake_response(success?: false, humidity: 10.0)
        weather.responses << response_three
        expect( weather.humidity ).to eq 25.0
      end

      it "excludes nil values" do
        response_three = fake_response(humidity: nil)
        weather.responses << response_three
        expect( weather.humidity ).to eq 25.0
      end

      it "returns a weighted average humidity" do
        response_one.stub(weight: 3)
        response_two.stub(weight: 1)
        expect( weather.humidity ).to eq 22.5
      end
    end

    describe "#dew_point" do
      let(:response_one) { fake_response(dew_point: Data::Temperature.new(:metric, 20)) }
      let(:response_two) { fake_response(dew_point: Data::Temperature.new(:metric, 30)) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average dew_point" do
        expect( weather.dew_point ).to eq Data::Temperature.new(:metric, 25.0)
      end
    end

    describe "#heat_index" do
      let(:response_one) { fake_response(heat_index: Data::Temperature.new(:metric, 20)) }
      let(:response_two) { fake_response(heat_index: Data::Temperature.new(:metric, 30)) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average heat_index" do
        expect( weather.heat_index ).to eq Data::Temperature.new(:metric, 25.0)
      end
    end

    describe "#wind_chill" do
      let(:response_one) { fake_response(wind_chill: Data::Temperature.new(:metric, 20)) }
      let(:response_two) { fake_response(wind_chill: Data::Temperature.new(:metric, 30)) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average wind_chill" do
        expect( weather.wind_chill ).to eq Data::Temperature.new(:metric, 25.0)
      end
    end

    describe "#pressure" do
      let(:response_one) { fake_response(pressure: Data::Pressure.new(:metric, 20)) }
      let(:response_two) { fake_response(pressure: Data::Pressure.new(:metric, 30)) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average pressure" do
        expect( weather.pressure ).to eq Data::Pressure.new(:metric, 25.0)
      end
    end

    describe "#visibility" do
      let(:response_one) { fake_response(visibility: Data::Distance.new(:metric, 20)) }
      let(:response_two) { fake_response(visibility: Data::Distance.new(:metric, 30)) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average visibility" do
        expect( weather.visibility ).to eq Data::Distance.new(:metric, 25.0)
      end
    end

    describe "#wind" do
      let(:response_one) { fake_response(wind: Data::Vector.new(:metric, 20)) }
      let(:response_two) { fake_response(wind: Data::Vector.new(:metric, 30)) }

      before { weather.responses = [response_one, response_two] }

      it "returns an average wind" do
        expect( weather.wind ).to eq Data::Vector.new(:metric, 25.0)
      end
    end
  end
end
