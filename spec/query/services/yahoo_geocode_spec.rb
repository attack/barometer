require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Barometer::Query::Service::YahooGeocode, vcr: {
  cassette_name: 'Service::YahooGeocode'
} do
  describe ".call" do
    subject { Barometer::Query::Service::YahooGeocode.call(query) }

    context 'when format is neither :weather_id or :woe_id' do
      let(:query) { Barometer::Query.new('90210') }

      it { should be_nil }

      context 'and a :weather_id conversion exists' do
        before { query.add_conversion(:weather_id, 'USNY0996') }

        it { should be_a Barometer::Data::Geo }
        its(:latitude) { should == 40.67 }
        its(:longitude) { should == -73.94 }
        its(:locality) { should == 'New York' }
        its(:region) { should == 'NY' }
        its(:country_code) { should == 'US' }

        its(:query) { should be_nil }
        its(:country) { should be_nil }
        its(:address) { should be_nil }
        its(:postal_code) { should be_nil }
      end

      context 'and a :woe_id conversion exists' do
        before { query.add_conversion(:woe_id, '2459115') }

        it { should be_a Barometer::Data::Geo }
        its(:latitude) { should == 40.71 }
        its(:longitude) { should == -74.01 }
        its(:locality) { should == 'New York' }
        its(:region) { should == 'NY' }
        its(:country) { should == 'United States' }

        its(:query) { should be_nil }
        its(:country_code) { should be_nil }
        its(:address) { should be_nil }
        its(:postal_code) { should be_nil }
      end
    end

    context 'when format is :weather_id' do
      let(:query) { Barometer::Query.new('USNY0996') }

      it { should be_a Barometer::Data::Geo }
      its(:latitude) { should == 40.67 }
      its(:longitude) { should == -73.94 }
      its(:locality) { should == 'New York' }
      its(:region) { should == 'NY' }
      its(:country_code) { should == 'US' }

      its(:query) { should be_nil }
      its(:country) { should be_nil }
      its(:address) { should be_nil }
      its(:postal_code) { should be_nil }
    end

    context 'when format is :woe_id' do
      let(:query) { Barometer::Query.new('w2459115') }

      it { should be_a Barometer::Data::Geo }
      its(:latitude) { should == 40.71 }
      its(:longitude) { should == -74.01 }
      its(:locality) { should == 'New York' }
      its(:region) { should == 'NY' }
      its(:country) { should == 'United States' }

      its(:query) { should be_nil }
      its(:country_code) { should be_nil }
      its(:address) { should be_nil }
      its(:postal_code) { should be_nil }
    end
  end
end
