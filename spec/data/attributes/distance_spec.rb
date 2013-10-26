require_relative '../../spec_helper'
require 'virtus'

module Barometer
  class TestClass
    include Virtus.model
    attribute :distance, Data::Attribute::Distance
  end

  describe Data::Attribute::Distance do
    let(:model) { TestClass.new }

    context 'when setting to nil' do
      it 'resets the value' do
        model.distance = Data::Distance.new(42.2)
        model.distance = nil
        expect( model.distance ).to be_nil
      end
    end

    context 'when setting with data of exact values' do
      it 'initializes Barometer::Data::Distance' do
        model.distance = [42.2]
        expect( model.distance ).to be_a Data::Distance
      end

      it 'prints correctly' do
        model.distance = [42.2]
        expect( model.distance.to_s ).to eq '42.2 km'
      end
    end

    context 'when setting to multiple values' do
      it 'initializes Barometer::Data::Distance' do
        model.distance = [42.2, 26.2]
        expect( model.distance ).to be_a Data::Distance
      end

      it 'prints correctly (as metric)' do
        model.distance = [42.2, 26.2]
        expect( model.distance.to_s ).to eq '42.2 km'
      end

      it 'prints correctly (as imperial)' do
        model.distance = [:imperial, 42.2, 26.2]
        expect( model.distance.to_s ).to eq '26.2 m'
      end
    end

    context 'when setting with Barometer::Data::Distance' do
      it 'uses the passed in value' do
        distance = Data::Distance.new(42.2)
        model.distance = distance

        expect( model.distance ).to eq distance
        expect( model.distance.object_id ).to eq distance.object_id
      end
    end
  end
end
