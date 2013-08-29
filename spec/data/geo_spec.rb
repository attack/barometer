require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Barometer::Data
  describe Geo do
    describe '#coordinates' do
      it 'joins latitude and longitude' do
        geo = Geo.new
        geo.longitude = '99.99'
        geo.latitude = '88.88'

        geo.coordinates.should == '88.88,99.99'
      end
    end

    describe '#to_s' do
      let(:geo) { Geo.new }

      it 'defaults to blank' do
        geo.to_s.should == ""
      end

      it 'uses the available data' do
        geo.address = 'address'
        geo.to_s.should == 'address'
        geo.locality = 'locality'
        geo.to_s.should == 'address, locality'
        geo.country_code = 'code'
        geo.to_s.should == 'address, locality, code'
      end
    end

    describe '#merge' do
      it 'leaves original target values' do
        target_geo = Geo.new
        target_geo.locality = 'foo'
        target_geo.postal_code = '90210'

        source_geo = Geo.new
        source_geo.postal_code = '10001'

        target_geo.merge(source_geo)
        target_geo.locality.should == 'foo'
        target_geo.postal_code.should == '90210'
      end

      it 'leaves blank target values' do
        target_geo = Geo.new
        target_geo.postal_code = ''

        source_geo = Geo.new
        source_geo.postal_code = '10001'

        target_geo.merge(source_geo)
        target_geo.postal_code.should == ''
      end

      it 'updates nil target values' do
        target_geo = Geo.new
        target_geo.country = nil

        source_geo = Geo.new
        source_geo.country = 'Foo Bar'

        target_geo.merge(source_geo)
        target_geo.country.should == 'Foo Bar'
      end

      it 'updates unset target values' do
        target_geo = Geo.new

        source_geo = Geo.new
        source_geo.latitude = 12.34
        source_geo.longitude = -56.78

        target_geo.merge(source_geo)
        target_geo.latitude.should == 12.34
        target_geo.longitude.should == -56.78
      end
    end
  end
end
