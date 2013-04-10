require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Barometer::Query do
  describe ".initialize" do
    describe "detecting the query format" do
      it "detects :short_zipcode" do
        query = Barometer::Query.new("90210")
        query.format.should == :short_zipcode
        query.country_code.should == "US"
      end

      it "detects :zipcode" do
        query = Barometer::Query.new("90210-5555")
        query.format.should == :zipcode
        query.country_code.should == "US"
      end

      it "detects :postalcode" do
        query = Barometer::Query.new("T5B 4M9")
        query.format.should == :postalcode
        query.country_code.should == "CA"
      end

      it "detects :icao" do
        query = Barometer::Query.new("KSFO")
        query.format.should == :icao
        query.country_code.should == "US"
      end

      it "detects :weather_id" do
        query = Barometer::Query.new("USGA0028")
        query.format.should == :weather_id
        query.country_code.should == "US"
      end

      it "detects :coordinates" do
        query = Barometer::Query.new("40.756054,-73.986951")
        query.format.should == :coordinates
        query.country_code.should be_nil
      end

      it "defaults to :geocode" do
        query = Barometer::Query.new("New York, NY")
        query.format.should == :geocode
        query.country_code.should be_nil
      end
    end
  end

  describe "#add_conversion" do
    let(:query) { Barometer::Query.new('foo') }

    it "adds a new conversion" do
      query.add_conversion(:geocode, 'Paris')
      query.get_conversion(:geocode).q.should == 'Paris'
    end

    it "overrides an existing conversion" do
      query.add_conversion(:geocode, 'Paris')

      query.add_conversion(:geocode, 'Berlin')
      query.get_conversion(:geocode).q.should == 'Berlin'
    end
  end

  describe "#get_conversion" do
    let(:query) { Barometer::Query.new('foo') }

    context "when the requested format is that of the query" do
      it "returns self instead of a conversion" do
        query = Barometer::Query.new('Paris')

        query.add_conversion(:geocode, 'Berlin')

        converted_query = query.get_conversion(:geocode)
        converted_query.q.should == 'Paris'
        converted_query.format.should == :geocode
      end
    end

    it "returns a saved conversion" do
      query.add_conversion(:geocode, 'Paris')

      converted_query = query.get_conversion(:geocode)
      converted_query.q.should == 'Paris'
      converted_query.format.should == :geocode
    end

    it "returns one saved conversion, when asked for multiple" do
      query.add_conversion(:geocode, 'Paris')

      converted_query = query.get_conversion(:zipcode, :geocode)
      converted_query.format.should == :geocode
    end

    it "respects preference order" do
      query.add_conversion(:geocode, 'Paris')
      query.add_conversion(:woe_id, '615702')

      converted_query = query.get_conversion(:geocode, :woe_id)
      converted_query.format.should == :geocode
    end

    it "returns nil if nothing found" do
      query.get_conversion(:geocode).should be_nil
    end

    it "includes the current country code value" do
      query.add_conversion(:geocode, 'Paris')

      query.country_code = nil
      query.get_conversion(:geocode, :woe_id).country_code.should be_nil

      query.country_code = 'FR'
      query.get_conversion(:geocode, :woe_id).country_code.should == 'FR'
    end

    it "includes the current geo value" do
      query = Barometer::Query.new('34.1030032,-118.4104684')
      query.add_conversion(:geocode, 'Paris')
      query.geo = { :foo => 'bar' }
      query.get_conversion(:geocode, :woe_id).geo.should == { :foo => 'bar' }
    end
  end

  describe "#convert!" do
    describe "when the query can be converted directly to the requested format" do
      it "creates a conversion for the requested format" do
        coordinates = Barometer::ConvertedQuery.new('12.34,-56.78', :coordinates)
        coordinates_converter = double(:converter_instance, :call => coordinates, :to_a => [coordinates_converter])
        coordinates_converter_klass = double(:coordinates_converter, :new => coordinates_converter)

        Barometer::Converters.stub(:find_all => coordinates_converter_klass)

        query = Barometer::Query.new('90210')

        converted_query = query.convert!(:coordinates)
        converted_query.q.should == '12.34,-56.78'
        converted_query.format.should == :coordinates
        converted_query.country_code.should be_nil
      end
    end

    describe "when the query can be converted via geocoding to the requested format" do
      it "creates a conversion for the requested format" do
        coordinates = Barometer::ConvertedQuery.new('12.34,-56.78', :coordinates)
        coordinates_converter = double(:converter_instance, :call => coordinates)
        coordinates_converter_klass = double(:coordinates_converter, :new => coordinates_converter)

        geocode = Barometer::ConvertedQuery.new('Foo Bar', :geocode)
        geocode_converter = double(:geocode_converter_instance, :call => geocode)
        geocode_converter_klass = double(:geocode_converter, :new => geocode_converter)

        Barometer::Converters.stub(:find_all => [geocode_converter_klass, coordinates_converter_klass])

        query = Barometer::Query.new('90210')

        converted_query = query.convert!(:coordinates)
        converted_query.q.should == '12.34,-56.78'
        converted_query.format.should == :coordinates
        converted_query.country_code.should be_nil
      end
    end

    describe "when the query cannot be converted to the requested format" do
      it "raises ConversionNotPossible" do
        query = Barometer::Query.new('90210')

        Barometer::Converters.stub(:find_all => nil)

        expect {
          query.convert!(:zipcode)
        }.to raise_error{ Barometer::Query::ConversionNotPossible }
      end
    end
  end
end
