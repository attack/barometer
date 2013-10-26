require_relative '../../spec_helper'
require 'virtus'

module Barometer
  class TestClass
    include Virtus.model
    attribute :sun, Data::Attribute::Sun
  end

  describe Data::Attribute::Sun do
    let(:model) { TestClass.new }

    context 'when setting to nil' do
      it 'resets the value' do
        model.sun = Barometer::Data::Sun.new(rise: Time.now, set: Time.now)
        model.sun = nil
        expect( model.sun ).to be_nil
      end
    end

    context 'when setting with Barometer::Data::Time' do
      it 'uses the passed in value' do
        rise = Time.utc(2013, 02, 10, 6, 0, 0)
        set = Time.utc(2013, 02, 10, 6, 0, 0)
        sun = Barometer::Data::Sun.new(rise: rise, set: set)
        model.sun = sun

        expect( model.sun ).to eq sun
        expect( model.sun.object_id ).to eq sun.object_id
      end
    end
  end
end
