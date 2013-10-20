require_relative '../../spec_helper'

describe Barometer::Query::Service::GoogleGeocode, vcr: {
  cassette_name: 'Service::GoogleGeocode'
} do
  describe '.call' do
    subject { Barometer::Query::Service::GoogleGeocode.call(query) }

    context 'when the query is a :zipcode' do
      let(:query) { Barometer::Query.new('90210') }

      it { should be_a Barometer::Data::Geo }
      its(:query) { should == '90210' }
      its(:latitude) { should == 34.1030032 }
      its(:longitude) { should == -118.4104684 }
      its(:locality) { should == 'Beverly Hills' }
      its(:region) { should == 'CA' }
      its(:country) { should == 'United States' }
      its(:country_code) { should == 'US' }
      its(:address) { should be_nil }
      its(:postal_code) { should == '90210' }
    end

    context 'when the query is a city/region' do
      let(:query) { Barometer::Query.new('New York, NY') }

      it { should be_a Barometer::Data::Geo }
      its(:query) { should == 'New York, NY, US' }
      its(:latitude) { should == 40.7143528 }
      its(:longitude) { should == -74.00597309999999 }
      its(:locality) { should == 'New York' }
      its(:region) { should == 'NY' }
      its(:country) { should == 'United States' }
      its(:country_code) { should == 'US' }
      its(:address) { should be_nil }
      its(:postal_code) { should be_nil }
    end

    context 'when the query is :coordinates' do
      let(:query) { Barometer::Query.new('47,-114') }

      it { should be_a Barometer::Data::Geo }
      its(:query) { should be_nil }
      its(:latitude) { should == 47.000623 }
      its(:longitude) { should == -114.0016495 }
      its(:locality) { should == 'Missoula' }
      its(:region) { should == 'MT' }
      its(:country) { should == 'United States' }
      its(:country_code) { should == 'US' }
      its(:address) { should be_nil }
      its(:postal_code) { should == '59808' }
    end
  end
end
