require_relative '../../spec_helper'
require 'virtus'

module Barometer
  class TestClass
    include Virtus.model
    attribute :time, Data::Attribute::Time
  end

  describe Data::Attribute::Time do
    let(:model) { TestClass.new }

    context 'when nothing has been set' do
      it 'returns nil' do
        expect( model.time ).to be_nil
      end
    end

    context 'when setting to nil' do
      it 'resets the value' do
        model.time = '2012-10-04', '%Y-%d-%m'
        model.time = nil
        expect( model.time ).to be_nil
      end
    end

    context 'when setting with data to be interpretted as a time' do
      it 'sets the value' do
        model.time = 2012, 10, 4, 5, 30, 45
        expect( model.time ).to eq ::Time.utc(2012, 10, 4, 5, 30, 45)
      end
    end

    context 'when setting with data to parse' do
      it 'sets the value' do
        model.time = '2012-10-4 5:30:45 pm UTC'
        expect( model.time ).to eq ::Time.utc(2012, 10, 4, 17, 30, 45)
      end
    end

    context 'when setting with data to parse (including format)' do
      it 'sets the value' do
        model.time = '2012-10-04', '%Y-%d-%m'
        expect( model.time ).to eq ::Time.utc(2012, 4, 10)
      end
    end

    context 'when setting with Time' do
      it 'uses the passed in value' do
        time = ::Time.now.utc
        model.time = time

        expect( model.time ).to be_a ::Time
        expect( model.time.object_id ).to eq time.object_id
      end
    end
  end
end
