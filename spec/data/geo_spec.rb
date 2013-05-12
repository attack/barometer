require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::Geo do
  describe '#coordinates' do
    it 'joins latitude and longitude' do
      geo = Barometer::Data::Geo.new
      geo.longitude = '99.99'
      geo.latitude = '88.88'

      geo.coordinates.should == '88.88,99.99'
    end
  end

  describe '#to_s' do
    let(:geo) { Barometer::Data::Geo.new }

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
end
