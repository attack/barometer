require_relative '../spec_helper'

module Barometer::Data
  describe Vector do
    describe '.initialize' do
      it 'sets kph' do
        vector = Vector.new(16.09, nil, nil)
        expect( vector.kph ).to eq 16.09
      end

      it 'sets mph' do
        vector = Vector.new(nil, 10, nil)
        expect( vector.mph ).to eq 10
      end

      it 'sets bearing' do
        vector = Vector.new(nil, nil, 270)
        expect( vector.bearing ).to eq 270
      end

      it 'defaults to metric' do
        vector = Vector.new(20, 270)
        expect( vector.to_s ).to eq '20 kph @ 270 degrees'
      end
    end

    describe '#mph' do
      it 'returns known value as mph' do
        vector = Vector.new(:imperial, 10, nil)
        expect( vector.mph ).to eq 10
      end
    end

    describe '#kph' do
      it 'returns known value as kph' do
        vector = Vector.new(:metric, 20, nil)
        expect( vector.kph ).to eq 20
      end
    end

    describe '#units' do
      context 'when vector is metric' do
        it 'returns kph' do
          vector = Vector.new(:metric, 20.0, 10.0, nil)
          expect( vector.units ).to eq 'kph'
        end
      end

      context 'when vector is imperial' do
        it 'returns mph' do
          vector = Vector.new(:imperial, 20.0, 10.0, nil)
          expect( vector.units ).to eq 'mph'
        end
      end
    end

    describe '#to_s' do
      context 'when vector is metric' do
        it 'returns kph only when no bearing' do
          vector = Vector.new(:metric, 16, nil, nil)
          expect( vector.to_s ).to eq '16 kph'
        end

        it 'returns bearing only when no kph' do
          vector = Vector.new(:metric, nil, nil, 270)
          expect( vector.to_s ).to eq '270 degrees'
        end

        it 'returns kph and bearing' do
          vector = Vector.new(:metric, 16, nil, 270)
          expect( vector.to_s ).to eq '16 kph @ 270 degrees'
        end
      end

      context 'when vector is imperial' do
        it 'returns mph only when no bearing' do
          vector = Vector.new(:imperial, nil, 10, nil)
          expect( vector.to_s ).to eq '10 mph'
        end

        it 'returns bearing only when no mph' do
          vector = Vector.new(:imperial, nil, nil, 270)
          expect( vector.to_s ).to eq '270 degrees'
        end

        it 'returns mph and bearing' do
          vector = Vector.new(:imperial, nil, 10, 270)
          expect( vector.to_s ).to eq '10 mph @ 270 degrees'
        end
      end
    end

    describe '#nil?' do
      it 'returns false if only bearing set' do
        vector = Vector.new(nil, nil, 270)
        expect( vector ).not_to be_nil
      end
    end
  end
end
