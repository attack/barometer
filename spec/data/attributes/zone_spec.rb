require_relative '../../spec_helper'
require 'virtus'

module Barometer
  class TestClass
    include Virtus.model
    attribute :timezone, Data::Attribute::Zone
  end

  describe Data::Attribute::Zone do
    let(:model) { TestClass.new }

    context 'when nothing has been set' do
      it 'returns nil' do
        expect( model.timezone ).to be_nil
      end
    end

    context 'when setting to nil' do
      it 'resets the value' do
        model.timezone = Barometer::Data::Zone.new('MST')
        model.timezone = nil
        expect( model.timezone ).to be_nil
      end
    end

    context 'when setting with data to be interpretted as a time zone' do
      it 'sets the value' do
        model.timezone = Barometer::Data::Zone.new('PDT')
        expect( model.timezone.code ).to eq 'PDT'
      end
    end
  end
end
