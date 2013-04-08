require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Barometer::Query, :vcr => {
  :cassette_name => "Query"
} do
  before(:each) do
    @short_zipcode = "90210"
    @zipcode = @short_zipcode
    @long_zipcode = "90210-5555"
    @weather_id = "USGA0028"
    @postal_code = "T5B 4M9"
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
    @icao = "KSFO"

    # actual conversions
    @zipcode_to_coordinates = "34.1030032,-118.4104684"
    @zipcode_to_geocode = "Beverly Hills, CA, United States"
    @zipcode_to_weather_id = "USCA0090"
    @postalcode_to_coordinates = "53.5721719,-113.4551835"
    @geocode_to_coordinates = "40.7143528,-74.0059731"
    @geocode_to_weather_id = "USNY0996"
    @coordinates_to_geocode = "Manhattan, NY, United States"
    @coordinates_to_weather_id = "USNY0996"
    @icao_to_coordinates = "37.615223,-122.389979"
    @icao_to_geocode = "San Francisco, CA, United States"
    @icao_to_weather_id = "USCA0987"
  end

  describe "#add_conversion" do
    let(:query) { Barometer::Query.new('foo') }

    it "adds a new conversion" do
      expect {
        query.add_conversion(:geocode, 'Paris')
      }.to change{ query.conversions[:geocode] }.from(nil).to('Paris')
    end

    it "overrides an existing conversion" do
      query.add_conversion(:geocode, 'Paris')

      expect {
        query.add_conversion(:geocode, 'Berlin')
      }.to change{ query.conversions[:geocode] }.from('Paris').to('Berlin')
    end
  end

  describe "#get_conversion" do
    let(:query) { Barometer::Query.new('foo') }

    context "when the requested format is that of the query" do
      it "returns self instead of a conversion" do
        query.q = 'Paris'
        query.format = :geocode

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
      query.add_conversion(:geocode, 'Paris')

      query.geo = nil
      query.get_conversion(:geocode, :woe_id).geo.should be_nil
      query.get_conversion(:geocode, :woe_id).latitude.should be_nil
      query.get_conversion(:geocode, :woe_id).longitude.should be_nil

      query.format = :coordinates
      query.q = "34.1030032,-118.4104684"
      query.geo = { :foo => 'bar' }
      query.get_conversion(:geocode, :woe_id).geo.should == { :foo => 'bar' }
      query.get_conversion(:geocode, :woe_id).latitude.should == "34.1030032"
      query.get_conversion(:geocode, :woe_id).longitude.should == "-118.4104684"
    end
  end

  describe "#convert!" do
    describe "when the query can be converted directly to the requested format" do
      it "creates a conversion for the requested format" do
        coordinates = Barometer::ConvertedQuery.new('12.34,-56.78', :coordinates)
        coordinates_converter = double(:converter_instance, :call => coordinates)
        coordinates_converter_klass = double(:coordinates_converter, :new => coordinates_converter)

        Barometer::Converters.stub(:find_all => coordinates_converter_klass)

        query = Barometer::Query.new('90210')
        query.format = :short_zipcode

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
        query.format = :short_zipcode

        converted_query = query.convert!(:coordinates)
        converted_query.q.should == '12.34,-56.78'
        converted_query.format.should == :coordinates
        converted_query.country_code.should be_nil
      end
    end

    describe "when the query cannot be converted to the requested format" do
      it "raises ConversionNotPossible" do
        query = Barometer::Query.new('90210')
        query.format = :short_zipcode

        Barometer::Converters.stub(:find_all => nil)

        expect {
          query.convert!(:zipcode)
        }.to raise_error{ Barometer::Query::ConversionNotPossible }
      end
    end
  end

  describe "determines the query format" do
    before(:each) do
      @query = Barometer::Query.new
      @query.country_code.should be_nil
    end

    it "recognizes a short zip code" do
      @query.q = @short_zipcode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :short_zipcode
      @query.country_code.should == "US"
    end

    it "recognizes a zip code" do
      @query.q = @long_zipcode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :zipcode
      @query.country_code.should == "US"
    end

    it "recognizes a postal code" do
      @query.q = @postal_code
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :postalcode
      @query.country_code.should == "CA"
    end

    it "recognizes icao" do
      @query.q = @icao
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :icao
      @query.country_code.should == "US"
    end

    it "recognizes weather_id" do
      @query.q = @weather_id
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :weather_id
      @query.country_code.should == "US"
    end

    it "recognizes latitude/longitude" do
      @query.q = @coordinates
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :coordinates
      @query.country_code.should be_nil
    end

    it "defaults to a general geo_location" do
      @query.q = @geocode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :geocode
      @query.country_code.should be_nil
    end
  end

  describe "when initialized" do
    before(:each) do
      @query = Barometer::Query.new
    end

    it "attempts query conversion when reading q (if format known)" do
      query = Barometer::Query.new(@geocode)
      query.format.should == :geocode
      Barometer::Query::Format::Geocode.should_receive(:convert_query).once.with(@geocode).and_return(@geocode)
      query.q.should == @geocode
    end

    it "does not attempt query conversion when reading q (if format unknown)" do
      @query.format.should be_nil
      Barometer::Query::Format.should_not_receive(:convert_query)
      @query.q.should be_nil
    end

    it "sets the query" do
      query = Barometer::Query.new(@geocode)
      query.q.should == @geocode
    end

    it "determines the format" do
      query = Barometer::Query.new(@geocode)
      query.format.should_not be_nil
    end

    it "returns latitude for when recognized as coordinates" do
      @query.q = @coordinates
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :coordinates
      @query.latitude.should == @coordinates.split(',')[0]
    end

    it "returns longitude for when recognized as coordinates" do
      @query.q = @coordinates
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :coordinates
      @query.longitude.should == @coordinates.split(',')[1]
    end

    it "returns nothing for latitude/longitude when not coordinates" do
      @query.q = @geocode
      @query.format.should be_nil
      @query.analyze!
      @query.format.to_sym.should == :geocode
      @query.latitude.should be_nil
      @query.longitude.should be_nil
    end
  end

  describe "when returning the query to a Weather API" do
    describe "and the query is already the preferred format" do
      it "returns the short_zipcode untouched" do
        query = Barometer::Query.new(@short_zipcode)
        query.convert!(:short_zipcode).q.should == @short_zipcode
        query.country_code.should == "US"
      end

      it "returns the long_zipcode untouched" do
        query = Barometer::Query.new(@long_zipcode)
        query.convert!(:zipcode).q.should == @long_zipcode
        query.country_code.should == "US"
      end

      it "returns the postalcode untouched" do
        query = Barometer::Query.new(@postal_code)
        query.convert!(:postalcode).q.should == @postal_code
        query.country_code.should == "CA"
      end

      it "returns the icao untouched" do
        query = Barometer::Query.new(@icao)
        query.convert!(:icao).q.should == @icao
      end

      it "returns the coordinates untouched" do
        query = Barometer::Query.new(@coordinates)
        query.convert!(:coordinates).q.should == @coordinates
      end

      it "returns the geocode untouched" do
        query = Barometer::Query.new(@geocode)
        query.convert!(:geocode).q.should == @geocode
      end
    end

    describe "and the query needs converting" do
      describe "with an intial format of :short_zipcode," do
        before(:each) do
          @query = Barometer::Query.new(@short_zipcode)
        end

        it "converts to zipcode" do
          query = @query.convert!(:zipcode)
          query.q.should == @zipcode
          query.country_code.should == "US"
        end

        it "converts to coordinates" do
          query = @query.convert!(:coordinates)
          query.q.should == @zipcode_to_coordinates
          query.country_code.should == "US"
        end

        it "converts to geocode" do
          query = @query.convert!(:geocode)
          query.q.should == @zipcode_to_geocode
          query.country_code.should == "US"
        end

        it "converts to weather_id" do
          query = @query.convert!(:weather_id)
          query.q.should == @zipcode_to_weather_id
          query.country_code.should == "US"
        end
      end

      describe "with an intial format of :zipcode," do
        before(:each) do
          @query = Barometer::Query.new(@zipcode)
          Barometer.force_geocode = false
        end

        it "converts to coordinates" do
          query = @query.convert!(:coordinates)
          query.q.should == @zipcode_to_coordinates
          query.country_code.should == "US"
        end

        it "converts to geocode" do
          query = @query.convert!(:geocode)
          query.q.should == @zipcode_to_geocode
          query.country_code.should == "US"
        end

        it "converts to weather_id" do
          query = @query.convert!(:weather_id)
          query.q.should == @zipcode_to_weather_id
          query.country_code.should == "US"
        end
      end

      describe "with an intial format of :postalcode," do
        before(:each) do
          @query = Barometer::Query.new(@postal_code)
        end

        it "converts to coordinates" do
          query = @query.convert!(:coordinates)
          query.q.should == @postalcode_to_coordinates
          query.country_code.should == "CA"
        end
      end

      describe "with an intial format of :icao," do
        before(:each) do
          @query = Barometer::Query.new(@icao)
        end

        it "converts to coordinates" do
          query = @query.convert!(:coordinates)
          query.q.should == @icao_to_coordinates
          query.country_code.should == "US"
        end

        it "converts to geocode" do
          query = @query.convert!(:geocode)
          query.q.should == @icao_to_geocode
          query.country_code.should == "US"
        end

        it "converts to weather_id" do
          query = @query.convert!(:weather_id)
          query.q.should == @icao_to_weather_id
          query.country_code.should == "US"
        end
      end

      describe "with an intial format of :geocode," do
        before(:each) do
          @query = Barometer::Query.new(@geocode)
        end

        it "converts to coordinates" do
          query = @query.convert!(:coordinates)

          query_coords = query.q.split(',').map{|c| c.to_f}
          expected_coords = @geocode_to_coordinates.split(',').map{|c| c.to_f}

          query_coords[0].should be_within(0.00001).of(expected_coords[0])
          query_coords[1].should be_within(0.00001).of(expected_coords[1])
          query.country_code.should == "US"
        end

        it "converts to weather_id" do
          query = @query.convert!(:weather_id)
          query.q.should == @geocode_to_weather_id
          # query.country_code.should == "US"
        end
      end

      describe "with an intial format of :coordinates," do
        before(:each) do
          @query = Barometer::Query.new(@coordinates)
        end

        it "converts to geocode" do
          query = @query.convert!(:geocode)
          query.q.should == @coordinates_to_geocode
          query.country_code.should == "US"
        end

        it "converts to weather_id" do
          query = @query.convert!(:weather_id)
          query.q.should == @coordinates_to_weather_id
          query.country_code.should == "US"
        end
      end
    end
  end
end
