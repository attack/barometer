require_relative '../../spec_helper'
require 'virtus'

module Barometer
  class TestClass
    include Virtus.model
    attribute :temperature, Data::Attribute::Temperature
  end

  describe Data::Attribute::Temperature do
    let(:model) { TestClass.new }

    context 'when setting to nil' do
      it 'resets the value' do
        model.temperature = Data::Temperature.new(12)
        model.temperature = nil
        expect( model.temperature ).to be_nil
      end
    end

    context 'when setting with data of exact values' do
      it 'initializes Barometer::Data::Temperature' do
        model.temperature = [12]
        expect( model.temperature ).to be_a Data::Temperature
      end

      it 'defaults to :metric' do
        model.temperature = [12]
        expect( model.temperature.to_s ).to eq '12 C'
      end
    end

    context 'when setting to multiple values' do
      it 'initializes Barometer::Data::Temperature' do
        model.temperature = [12, 53]
        expect( model.temperature ).to be_a Data::Temperature
      end

      it 'prints correctly (as metric)' do
        model.temperature = [12, 53]
        expect( model.temperature.to_s ).to eq '12 C'
      end

      it 'prints correctly (as imperial)' do
        model.temperature = [:imperial, 12, 53]
        expect( model.temperature.to_s ).to eq '53 F'
      end
    end

    context 'when setting with Barometer::Data::Temperature' do
      it 'uses the passed in value' do
        temperature = Data::Temperature.new(12)
        model.temperature = temperature

        expect( model.temperature ).to eq temperature
        expect( model.temperature.object_id ).to eq temperature.object_id
      end
    end
  end
end
