require_relative '../../spec_helper'

module Barometer::WeatherService
  describe WeatherBug::Query do
    describe '#to_param' do
      let(:converted_query) { double(:converted_query).as_null_object }
      let(:query) { WeatherBug::Query.new(converted_query) }

      context 'when the query is a :short_zipcode' do
        before { converted_query.stub(format: :short_zipcode, q: '90210') }

        it 'includes the correct parameters' do
          expect( query.to_param[:zipCode] ).to eq '90210'
        end
      end

      context 'and the query is a :coordinates' do
        let(:geo) { double(:geo, latitude: '11.22', longitude: '33.44') }
        before { converted_query.stub(format: :coordinates, geo: geo) }

        it 'includes the correct parameters' do
          expect( query.to_param[:lat] ).to eq '11.22'
          expect( query.to_param[:long] ).to eq '33.44'
        end
      end

      context 'and the query is metric' do
        before { converted_query.stub(metric?: true) }

        it 'includes the correct parameters' do
          expect( query.to_param[:UnitType] ).to eq '1'
        end
      end

      context 'and the query is imperial' do
        before { converted_query.stub(metric?: false) }

        it 'includes the correct parameters' do
          expect( query.to_param[:UnitType] ).to eq '0'
        end
      end
    end
  end
end
