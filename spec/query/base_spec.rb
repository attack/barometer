require_relative '../spec_helper'

module Barometer
  describe Query::Base do
    describe '.initialize' do
      describe 'detecting the query format' do
        it 'detects :short_zipcode' do
          query = Query::Base.new('90210')
          query.format.should == :short_zipcode
          query.geo.country_code.should == 'US'
        end

        it 'detects :zipcode' do
          query = Query::Base.new('90210-5555')
          query.format.should == :zipcode
          query.geo.country_code.should == 'US'
        end

        it 'detects :postalcode' do
          query = Query::Base.new('T5B 4M9')
          query.format.should == :postalcode
          query.geo.country_code.should == 'CA'
        end

        it 'detects :icao' do
          query = Query::Base.new('KSFO')
          query.format.should == :icao
          query.geo.country_code.should == 'US'
        end

        it 'detects :weather_id' do
          query = Query::Base.new('USGA0028')
          query.format.should == :weather_id
          query.geo.country_code.should == 'US'
        end

        it 'detects :coordinates' do
          query = Query::Base.new('40.756054,-73.986951')
          query.format.should == :coordinates
          query.geo.country_code.should be_nil
        end

        it 'defaults to :unknown' do
          query = Query::Base.new('New York, NY')
          query.format.should == :unknown
          query.geo.country_code.should be_nil
        end
      end
    end

    describe '#metric?' do
      it 'returns true when units are not specified' do
        query = Query::Base.new('New York, NY')
        expect( query ).to be_metric
      end

      it 'returns true when units are set to metric' do
        query = Query::Base.new('New York, NY', :metric)
        expect( query ).to be_metric
      end

      it 'returns false when units are set to imperial' do
        query = Query::Base.new('New York, NY', :imperial)
        expect( query ).not_to be_metric
      end
    end

    describe '#add_conversion' do
      let(:query) { Query::Base.new('foo') }

      it "adds a new conversion" do
        query.add_conversion(:geocode, 'Paris')
        query.get_conversion(:geocode).q.should == 'Paris'
      end

      it "overrides an existing conversion" do
        query.add_conversion(:geocode, 'Paris')

        query.add_conversion(:geocode, 'Berlin')
        query.get_conversion(:geocode).q.should == 'Berlin'
      end

      it "does not add a nil conversion" do
        query.add_conversion(:geocode, nil)
        query.get_conversion(:geocode).should be_nil
      end
    end

    describe '#get_conversion' do
      let(:query) { Query::Base.new('somewhere') }

      context 'when the requested format is that of the query' do
        it 'returns self instead of a conversion' do
          query = Query::Base.new('90210')

          query.add_conversion(:short_zipcode, '10001')

          converted_query = query.get_conversion(:short_zipcode)
          converted_query.q.should == '90210'
          converted_query.format.should == :short_zipcode
        end
      end

      it 'returns a saved conversion' do
        query.add_conversion(:geocode, 'Paris')

        converted_query = query.get_conversion(:geocode)
        converted_query.q.should == 'Paris'
        converted_query.format.should == :geocode
      end

      it 'returns one saved conversion, when asked for multiple' do
        query.add_conversion(:geocode, 'Paris')

        converted_query = query.get_conversion(:zipcode, :geocode)
        converted_query.format.should == :geocode
      end

      it 'respects preference order' do
        query.add_conversion(:geocode, 'Paris')
        query.add_conversion(:woe_id, '615702')

        converted_query = query.get_conversion(:geocode, :woe_id)
        converted_query.format.should == :geocode
      end

      it 'returns nil if nothing found' do
        query.get_conversion(:geocode).should be_nil
      end

      it 'includes the current country code value' do
        query.add_conversion(:geocode, 'Paris')

        query.geo.country_code = nil
        query.get_conversion(:geocode, :woe_id).geo.country_code.should be_nil

        query.geo.country_code = 'FR'
        query.get_conversion(:geocode, :woe_id).geo.country_code.should == 'FR'
      end

      it 'includes the current geo value' do
        query = Query::Base.new('34.1030032,-118.4104684')
        query.add_conversion(:geocode, 'Paris')

        geo = Data::Geo.new
        geo.locality = 'New York'
        query.geo = geo

        query.get_conversion(:geocode, :woe_id).geo.to_s.should == geo.to_s
      end

      it 'includes the current units value' do
        query = Query::Base.new('34.1030032,-118.4104684', :imperial)
        query.add_conversion(:geocode, 'Paris')

        expect( query.get_conversion(:geocode, :woe_id).units ).to eq :imperial
      end
    end

    describe '#convert!' do
      context 'when the query can be converted directly to the requested format' do
        it 'creates a conversion for the requested format' do
          coordinates = ConvertedQuery.new('12.34,-56.78', :coordinates)
          coordinates_converter = double(:converter_instance, call: coordinates)
          coordinates_converter_klass = double(:coordinates_converter, new: coordinates_converter)

          Query::Converter.stub(find_all: [{coordinates: coordinates_converter_klass}])

          query = Query::Base.new('90210')

          converted_query = query.convert!(:coordinates)
          converted_query.q.should == '12.34,-56.78'
          converted_query.format.should == :coordinates
        end
      end

      context 'when the query has already been converted to the requested format' do
        it 'uses the existing conversion' do
          query = Query::Base.new('10001')
          query.add_conversion(:coordinates, '12.34,-56.78')

          converted_query = query.convert!(:coordinates)
          converted_query.q.should == '12.34,-56.78'
          converted_query.format.should == :coordinates
        end
      end

      context 'when the query can be converted via geocoding to the requested format' do
        it 'creates a conversion for the requested format' do
          coordinates = ConvertedQuery.new('12.34,-56.78', :coordinates)
          coordinates_converter = double(:converter_instance, call: coordinates)
          coordinates_converter_klass = double(:coordinates_converter, new: coordinates_converter)

          geocode = ConvertedQuery.new('Foo Bar', :geocode)
          geocode_converter = double(:geocode_converter_instance, call: geocode)
          geocode_converter_klass = double(:geocode_converter, new: geocode_converter)

          Query::Converter.stub(find_all: [
            {geocode: geocode_converter_klass},
            {coordinates: coordinates_converter_klass}
          ])

          query = Query::Base.new('90210')

          converted_query = query.convert!(:coordinates)
          converted_query.q.should == '12.34,-56.78'
          converted_query.format.should == :coordinates
        end

        it 'uses any exisiting intermediate conversions' do
          coordinates = ConvertedQuery.new('12.34,-56.78', :coordinates)
          coordinates_converter = double(:converter_instance, call: coordinates)
          coordinates_converter_klass = double(:coordinates_converter, new: coordinates_converter, from: [:geocode])

          geocode_converter_klass = double(:geocode_converter)

          Query::Converter.stub(find_all: [
            {geocode: geocode_converter_klass},
            {coordinates: coordinates_converter_klass}
          ])

          query = Query::Base.new('90210')
          query.add_conversion(:geocode, 'Foo Bar')
          query.geo = Data::Geo.new.tap do |geo|
            geo.latitude = 12.34
            geo.longitude = -56.78
          end

          converted_query = query.convert!(:coordinates)
          converted_query.q.should == '12.34,-56.78'
          converted_query.format.should == :coordinates
        end
      end

      context 'when the query cannot be converted to the requested format' do
        it 'raises ConversionNotPossible' do
          query = Query::Base.new('90210')

          Query::Converter.stub(find_all: [])

          expect {
            query.convert!(:zipcode)
          }.to raise_error{ Query::ConversionNotPossible }
        end
      end
    end

    describe '#geo=' do
      it 'updates the current geo values' do
        query = Query::Base.new('90210')
        query.geo.tap do |geo|
          geo.locality = 'foo'
          geo.region = 'bar'
          geo.country_code = 'FB'
        end

        geo = Data::Geo.new
        geo.latitude = 12.34
        geo.longitude = -56.78

        query.geo = geo
        query.geo.locality.should == 'foo'
        query.geo.region.should == 'bar'
        query.geo.country_code.should == 'FB'
        query.geo.latitude.should == 12.34
        query.geo.longitude.should == -56.78
      end
    end

    describe '#to_s' do
      it 'returns the query q value' do
        query = Query::Base.new('90210')
        query.to_s.should == '90210'
      end
    end
  end
end
