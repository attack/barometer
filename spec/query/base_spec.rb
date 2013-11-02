require_relative '../spec_helper'

module Barometer
  describe Query::Base do
    describe '.initialize' do
      describe 'detecting the query format' do
        it 'detects :short_zipcode' do
          query = Query::Base.new('90210')
          expect( query.format ).to eq :short_zipcode
          expect( query.geo.country_code ).to eq 'US'
        end

        it 'detects :zipcode' do
          query = Query::Base.new('90210-5555')
          expect( query.format ).to eq :zipcode
          expect( query.geo.country_code ).to eq 'US'
        end

        it 'detects :postalcode' do
          query = Query::Base.new('T5B 4M9')
          expect( query.format ).to eq :postalcode
          expect( query.geo.country_code ).to eq 'CA'
        end

        it 'detects :icao' do
          query = Query::Base.new('KSFO')
          expect( query.format ).to eq :icao
          expect( query.geo.country_code ).to eq 'US'
        end

        it 'detects :weather_id' do
          query = Query::Base.new('USGA0028')
          expect( query.format ).to eq :weather_id
          expect( query.geo.country_code ).to eq 'US'
        end

        it 'detects :coordinates' do
          query = Query::Base.new('40.756054,-73.986951')
          expect( query.format ).to eq :coordinates
          expect( query.geo.country_code ).to be_nil
          expect( query.geo.latitude ).to eq 40.756054
          expect( query.geo.longitude ).to eq -73.986951
        end

        it 'defaults to :unknown' do
          query = Query::Base.new('New York, NY')
          expect( query.format ).to eq :unknown
          expect( query.geo.country_code ).to be_nil
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
        expect( query.get_conversion(:geocode).q ).to eq 'Paris'
      end

      it "overrides an existing conversion" do
        query.add_conversion(:geocode, 'Paris')

        query.add_conversion(:geocode, 'Berlin')
        expect( query.get_conversion(:geocode).q ).to eq 'Berlin'
      end

      it "does not add a nil conversion" do
        query.add_conversion(:geocode, nil)
        expect( query.get_conversion(:geocode) ).to be_nil
      end
    end

    describe '#get_conversion' do
      let(:query) { Query::Base.new('somewhere') }

      context 'when the requested format is that of the query' do
        it 'returns self instead of a conversion' do
          query = Query::Base.new('90210')

          query.add_conversion(:short_zipcode, '10001')

          converted_query = query.get_conversion(:short_zipcode)
          expect( converted_query.q ).to eq '90210'
          expect( converted_query.format ).to eq :short_zipcode
        end
      end

      it 'returns a saved conversion' do
        query.add_conversion(:geocode, 'Paris')

        converted_query = query.get_conversion(:geocode)
        expect( converted_query.q ).to eq 'Paris'
        expect( converted_query.format ).to eq :geocode
      end

      it 'returns one saved conversion, when asked for multiple' do
        query.add_conversion(:geocode, 'Paris')

        converted_query = query.get_conversion(:zipcode, :geocode)
        expect( converted_query.format ).to eq :geocode
      end

      it 'respects preference order' do
        query.add_conversion(:zipcode, '12345')
        query.add_conversion(:geocode, 'Paris')
        query.add_conversion(:woe_id, '615702')

        converted_query = query.get_conversion(:geocode, :woe_id, :zipcode)
        expect( converted_query.format ).to eq :geocode
      end

      it 'returns nil if nothing found' do
        expect( query.get_conversion(:geocode) ).to be_nil
      end

      it 'includes the current country code value' do
        query.add_conversion(:geocode, 'Paris')

        query.geo = Data::Geo.new(country_code: nil)
        expect( query.get_conversion(:geocode, :woe_id).geo.country_code ).to be_nil

        query.geo = Data::Geo.new(country_code: 'FR')
        expect( query.get_conversion(:geocode, :woe_id).geo.country_code ).to eq 'FR'
      end

      it 'includes the current geo value' do
        query = Query::Base.new('34.1030032,-118.4104684')
        query.add_conversion(:geocode, 'Paris')

        geo = Data::Geo.new(locality: 'New York')
        query.geo = geo

        expect( query.get_conversion(:geocode, :woe_id).geo.to_s ).to eq geo.to_s
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
          expect( converted_query.q ).to eq '12.34,-56.78'
          expect( converted_query.format ).to eq :coordinates
        end
      end

      context 'when the query has already been converted to the requested format' do
        it 'uses the existing conversion' do
          query = Query::Base.new('10001')
          query.add_conversion(:coordinates, '12.34,-56.78')

          converted_query = query.convert!(:coordinates)
          expect( converted_query.q ).to eq '12.34,-56.78'
          expect( converted_query.format ).to eq :coordinates
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
          expect( converted_query.q ).to eq '12.34,-56.78'
          expect( converted_query.format ).to eq :coordinates
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
          query.geo = Data::Geo.new(latitude: 12.34, longitude: -56.78)

          converted_query = query.convert!(:coordinates)
          expect( converted_query.q ).to eq '12.34,-56.78'
          expect( converted_query.format ).to eq :coordinates
        end

        it 'returns a new intermediate conversion if preferred' do
          class FakeGeocodeConverter
            def initialize(query); @query = query; end
            def call
              @query.add_conversion(:woe_id, '12345678')
              @query.add_conversion(:geocode, 'Foo Bar')
            end
          end

          class FakeCoordinatesConverter
            def initialize(query); @query = query; end
            def call
              @query.add_conversion(:coordinates, '12.34,-56.78')
            end
          end

          Query::Converter.stub(find_all: [
            {geocode: FakeGeocodeConverter},
            {coordinates: FakeCoordinatesConverter}
          ])

          query = Query::Base.new('90210')

          converted_query = query.convert!(:woe_id, :coordinates)
          expect( converted_query.q ).to eq '12345678'
          expect( converted_query.format ).to eq :woe_id
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
        query.geo = Data::Geo.new(locality: 'foo', region: 'bar')

        geo = Data::Geo.new(latitude: 12.34, longitude: -56.78, country_code: 'FB')

        query.geo = geo
        expect( query.geo.locality ).to eq 'foo'
        expect( query.geo.region ).to eq 'bar'
        expect( query.geo.country_code ).to eq 'US'
        expect( query.geo.latitude ).to eq 12.34
        expect( query.geo.longitude ).to eq -56.78
      end
    end

    describe '#to_s' do
      it 'returns the query q value' do
        query = Query::Base.new('90210')
        expect( query.to_s ).to eq '90210'
      end
    end
  end
end
