require_relative '../spec_helper'

module Barometer::Data
  describe Distance do
    describe '.initialize' do
      it 'sets km' do
        distance = Distance.new(42.2, nil)
        expect( distance.km ).to eq 42.2
      end

      it 'sets m' do
        distance = Distance.new(nil, 26.2)
        expect( distance.m ).to eq 26.2
      end

      it 'defaults to metric' do
        distance = Distance.new(42)
        expect( distance ).to be_metric
      end
    end

    describe '#m' do
      it 'returns known value as m' do
        distance = Distance.new(:imperial, 26)
        expect( distance.m ).to eq 26
      end
    end

    describe '#km' do
      it 'returns known value as km' do
        distance = Distance.new(:metric, 42)
        expect( distance.km ).to eq 42
      end
    end

    describe '#units' do
      context 'when distance is metric' do
        it 'returns km' do
          distance = Distance.new(:metric, 42.0)
          expect( distance.units ).to eq 'km'
        end
      end

      context 'when distance is imperial' do
        it 'returns m' do
          distance = Distance.new(:imperial, 26.0)
          expect( distance.units ).to eq 'm'
        end
      end
    end
  end
end
