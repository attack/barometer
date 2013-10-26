require_relative '../../spec_helper'
require 'virtus'

module Barometer
  class TestClass
    include Virtus.model
    attribute :vector, Data::Attribute::Vector
  end

  describe Data::Attribute::Vector do
    let(:model) { TestClass.new }

    context 'when setting to nil' do
      it 'resets the value' do
        model.vector = Data::Vector.new(12, 270)
        model.vector = nil
        model.vector.should be_nil
      end
    end

    context 'when setting with data of exact values' do
      it 'initializes Barometer::Data::Vector' do
        model.vector = [12, 270]
        expect( model.vector ).to be_a Data::Vector
      end

      it 'prints correctly' do
        model.vector = [12]
        expect( model.vector.to_s ).to eq '12 kph'
      end
    end

    context 'when setting with Barometer::Data::Vector' do
      it 'uses the passed in value' do
        vector = Data::Vector.new(12, 270)
        model.vector = vector

        expect( model.vector ).to eq vector
        expect( model.vector.object_id ).to eq vector.object_id
      end
    end
  end
end
