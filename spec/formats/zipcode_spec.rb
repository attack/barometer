require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Query::Zipcode" do

  before(:each) do
    @short_zipcode = "90210"
    @zipcode = @short_zipcode
    @long_zipcode = "90210-5555"
    @weather_id = "USGA0028"
    @postal_code = "T5B 4M9"
    @coordinates = "40.756054,-73.986951"
    @geocode = "New York, NY"
    @icao = "KSFO"
  end

  describe "and class methods" do

    it "returns a format" do
      Query::Format::Zipcode.format.should == :zipcode
    end

    it "returns a country" do
      Query::Format::Zipcode.country_code.should == "US"
      Query::Format::Zipcode.country_code("ignored").should == "US"
    end

    it "returns a regex" do
      Query::Format::Zipcode.regex.should_not be_nil
      Query::Format::Zipcode.regex.is_a?(Regexp).should be_true
    end

    it "returns the convertable_formats" do
      Query::Format::Zipcode.convertable_formats.should_not be_nil
      Query::Format::Zipcode.convertable_formats.is_a?(Array).should be_true
      Query::Format::Zipcode.convertable_formats.include?(:short_zipcode).should be_true
    end

    describe "is?," do

      before(:each) do
        @valid = "90210-5555"
        @invalid = "invalid"
      end

      it "recognizes a valid format" do
        Query::Format::Zipcode.is?(@valid).should be_true
      end

      it "recognizes non-valid format" do
        Query::Format::Zipcode.is?(@invalid).should be_false
      end

    end

    describe "when converting using 'to'," do

      it "requires a Barometer::Query object" do
        lambda { Query::Format::Zipcode.to }.should raise_error(ArgumentError)
        lambda { Query::Format::Zipcode.to("invalid") }.should raise_error(ArgumentError)
        query = Barometer::Query.new(@zipcode)
        query.is_a?(Barometer::Query).should be_true
        lambda { Query::Format::Zipcode.to(original_query) }.should_not raise_error(ArgumentError)
      end

      it "returns a Barometer::Query" do
        query = Barometer::Query.new(@short_zipcode)
        Query::Format::Zipcode.to(query).is_a?(Barometer::Query).should be_true
      end

      it "converts from short_zipcode" do
        query = Barometer::Query.new(@short_zipcode)
        query.format.should == :short_zipcode
        new_query = Query::Format::Zipcode.to(query)
        new_query.q.should == @short_zipcode
        new_query.format.should == :zipcode
        new_query.country_code.should == "US"
        new_query.geo.should be_nil
      end

      it "returns nil for other formats" do
        query = Barometer::Query.new(@zipcode)
        query.format = :zipcode
        query.format.should == :zipcode
        Query::Format::Zipcode.to(query).should be_nil

        query = Barometer::Query.new(@weather_id)
        query.format.should == :weather_id
        Query::Format::Zipcode.to(query).should be_nil

        query = Barometer::Query.new(@postal_code)
        query.format.should == :postalcode
        Query::Format::Zipcode.to(query).should be_nil

        query = Barometer::Query.new(@coordinates)
        query.format.should == :coordinates
        Query::Format::Zipcode.to(query).should be_nil

        query = Barometer::Query.new(@geocode)
        query.format.should == :geocode
        Query::Format::Zipcode.to(query).should be_nil

        query = Barometer::Query.new(@icao)
        query.format.should == :icao
        Query::Format::Zipcode.to(query).should be_nil
      end

    end

  end

end
