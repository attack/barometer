require_relative '../../spec_helper'
require 'virtus'

module Barometer
  class TestClass
    include Virtus.model
    attribute :pressure, Data::Attribute::Pressure
  end

  describe Data::Attribute::Pressure do
    let(:model) { TestClass.new }

    context 'when setting to nil' do
      it 'resets the value' do
        model.pressure = Data::Pressure.new(12)
        model.pressure = nil
        expect( model.pressure ).to be_nil
      end
    end

    context 'when setting with data of exact values' do
      it 'initializes Barometer::Data::Pressure' do
        model.pressure = [12]
        expect( model.pressure ).to be_a Data::Pressure
      end

      it 'prints correctly' do
        model.pressure = [12]
        expect( model.pressure.to_s ).to eq '12 mb'
      end
    end

    context 'when setting to multiple values' do
      it 'initializes Barometer::Data::Pressure' do
        model.pressure = [1234, 36]
        expect( model.pressure ).to be_a Data::Pressure
      end

      it 'prints correctly (as metric)' do
        model.pressure = [1234, 36]
        expect( model.pressure.to_s ).to eq '1234 mb'
      end

      it 'prints correctly (as imperial)' do
        model.pressure = [:imperial, 1234, 36]
        expect( model.pressure.to_s ).to eq '36 in'
      end
    end

    context 'when setting with Barometer::Data::Pressure' do
      it 'uses the passed in value' do
        pressure = Data::Pressure.new(12)
        model.pressure = pressure

        expect( model.pressure ).to eq pressure
        expect( model.pressure.object_id ).to eq pressure.object_id
      end
    end
  end
end
