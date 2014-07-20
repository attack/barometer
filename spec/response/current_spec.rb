require_relative '../spec_helper'

module Barometer::Response
  describe Current do
    it { is_expected.to have_field(:observed_at).of_type(Time) }
    it { is_expected.to have_field(:stale_at).of_type(Time) }
    it { is_expected.to have_field(:temperature).of_type(Barometer::Data::Temperature) }
    it { is_expected.to have_field(:dew_point).of_type(Barometer::Data::Temperature) }
    it { is_expected.to have_field(:heat_index).of_type(Barometer::Data::Temperature) }
    it { is_expected.to have_field(:wind_chill).of_type(Barometer::Data::Temperature) }
    it { is_expected.to have_field(:wind).of_type(Barometer::Data::Vector) }
    it { is_expected.to have_field(:pressure).of_type(Barometer::Data::Pressure) }
    it { is_expected.to have_field(:visibility).of_type(Barometer::Data::Distance) }
    it { is_expected.to have_field(:humidity).of_type(Float) }
    it { is_expected.to have_field(:icon).of_type(String) }
    it { is_expected.to have_field(:condition).of_type(String) }
    it { is_expected.to have_field(:sun).of_type(Barometer::Data::Sun) }

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
