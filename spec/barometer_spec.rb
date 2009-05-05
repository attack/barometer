require 'spec_helper'

describe "Barometer" do
  
  before(:each) do
    @config_hash = { 1 => [:wunderground] }
    @key = KEY
  end
  
  describe "and class methods" do
  
    it "defines selection" do
      Barometer::Base.respond_to?("config").should be_true
      Barometer::Base.config.should == { 1 => [:wunderground] }
      Barometer::Base.config = { 1 => [:yahoo] }
      Barometer::Base.config.should == { 1 => [:yahoo] }
      Barometer.config = @config_hash
    end
    
    it "returns a Weather Service driver" do
      Barometer.source(:wunderground).should == Barometer::Wunderground
    end
    
    it "sets the Graticule Google geocoding API key" do
      Barometer.respond_to?("google_geocode_key").should be_true
      Barometer.google_geocode_key.should be_nil
      Barometer.google_geocode_key = @key
      Barometer.google_geocode_key.should == @key
    end
    
    it "forces the geocoding of queries" do
      Barometer.respond_to?("force_geocode").should be_true
      Barometer.force_geocode.should be_false
      Barometer.force_geocode = true
      Barometer.force_geocode.should be_true
    end
    
    it "forces the geocoding of queries" do
      Barometer.respond_to?("force_geocode!").should be_true
      Barometer.force_geocode = false
      Barometer.force_geocode.should be_false
      Barometer.force_geocode!
      Barometer.force_geocode.should be_true
    end
    
    it "set the global service timeout" do
      Barometer.respond_to?("timeout").should be_true
      Barometer.timeout.should == 15
      Barometer.timeout = 5
      Barometer.timeout.should == 5
    end
    
  end

  describe "when initialized" do
    
    before(:each) do
      @barometer_direct = Barometer.new
      @barometer = Barometer::Base.new
    end
    
    it "responds to query" do
      @barometer_direct.respond_to?("query").should be_true
      @barometer.respond_to?("query").should be_true
    end
    
    it "sets the query" do
      query = "query"
      barometer = Barometer.new(query)
      barometer.query.is_a?(Barometer::Query)
      barometer.query.q.should == query
      
      barometer = Barometer::Base.new(query)
      barometer.query.is_a?(Barometer::Query)
      barometer.query.q.should == query
    end
    
    it "responds to weather" do
      @barometer.weather.is_a?(Barometer::Weather).should be_true
      @barometer_direct.weather.is_a?(Barometer::Weather).should be_true
    end
    
    it "responds to success" do
      @barometer.success.should be_false
      @barometer_direct.success.should be_false
      @barometer_direct.success?.should be_false
      @barometer_direct.success = true
      @barometer_direct.success?.should be_true
    end
    
  end
  
  describe "when measuring" do
    
    before(:each) do
      Barometer.google_geocode_key = @key
      query_term = "Calgary,AB"
      @barometer = Barometer::Base.new(query_term)
      @time = Time.now
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(query_term)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures/services/wunderground', 
          'current_calgary_ab.xml')
        )
      )
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(query_term)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures/services/wunderground',
          'forecast_calgary_ab.xml')
        )
      )
      FakeWeb.register_uri(:get, 
        "http://maps.google.com:80/maps/geo?gl=&q=Calgary%2CAB&output=xml&key=#{@key}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures/services/google',
          'calgary_ab.xml')
        )
      )
    end
    
    it "responds to measure" do
      @barometer.respond_to?("measure").should be_true
    end
    
    it "returns a Barometer::Weather object" do
      @barometer.measure.is_a?(Barometer::Weather).should be_true
    end
    
    it "raises OutOfSources if no services successful" do
      Barometer::Base.config = { 1 => [] }
      lambda { @barometer.measure }.should raise_error(Barometer::OutOfSources)
    end
    
    it "sets the weight" do
      Barometer::Base.config = { 1 => {:wunderground => {:weight => 2}} }
      @barometer.measure
      @barometer.weather.measurements.first.weight.should == 2
    end
    
  end

end
