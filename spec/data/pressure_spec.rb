require_relative '../spec_helper'

module Barometer::Data
  describe Pressure do
    describe '.initialize' do
      it 'sets mb' do
        distance = Pressure.new(721.64, nil)
        expect( distance.mb ).to eq 721.64
      end

      it 'sets in' do
        distance = Pressure.new(nil, 21.31)
        expect( distance.in ).to eq 21.31
      end

      it 'defaults to metric' do
        distance = Pressure.new(721.64)
        expect( distance ).to be_metric
      end
    end

    describe '#in' do
      it 'returns known value as in' do
        distance = Pressure.new(:imperial, 21)
        expect( distance.in ).to eq 21
      end
    end

    describe '#mb' do
      it 'returns known value as mb' do
        distance = Pressure.new(:metric, 721)
        expect( distance.mb ).to eq 721
      end
    end

    describe '#units' do
      context 'when distance is metric' do
        it 'returns mb' do
          distance = Pressure.new(:metric, 721.0, 21.0)
          expect( distance.units ).to eq 'mb'
        end
      end

      context 'when distance is imperial' do
        it 'returns in' do
          distance = Pressure.new(:imperial, 721.0, 21.0)
          expect( distance.units ).to eq 'in'
        end
      end
    end
  end
end
