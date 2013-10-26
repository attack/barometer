require_relative '../spec_helper'

module Barometer::Response
  describe Current do
    it { should have_field(:observed_at).of_type(Time) }
    it { should have_field(:stale_at).of_type(Time) }
    it { should have_field(:temperature).of_type(Barometer::Data::Temperature) }
    it { should have_field(:dew_point).of_type(Barometer::Data::Temperature) }
    it { should have_field(:heat_index).of_type(Barometer::Data::Temperature) }
    it { should have_field(:wind_chill).of_type(Barometer::Data::Temperature) }
    it { should have_field(:wind).of_type(Barometer::Data::Vector) }
    it { should have_field(:pressure).of_type(Barometer::Data::Pressure) }
    it { should have_field(:visibility).of_type(Barometer::Data::Distance) }
    it { should have_field(:humidity).of_type(Float) }
    it { should have_field(:icon).of_type(String) }
    it { should have_field(:condition).of_type(String) }
    it { should have_field(:sun).of_type(Barometer::Data::Sun) }

    describe '#complete?' do
      let(:current) { Current.new }

      it 'returns true when the temperature is present' do
        current.temperature = 10
        expect( current ).to be_complete
      end

      it 'returns false when there is no temperature' do
        current.temperature = nil
        expect( current ).not_to be_complete
      end
    end
  end
end
