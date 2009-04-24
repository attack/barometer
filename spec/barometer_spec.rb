require 'spec_helper'

describe "Barometer" do
  
  before(:each) do
    @preference_hash = { 1 => [:wunderground] }
  end
  
  describe "and class methods" do
  
    it "defines selection" do
      Barometer::Base.respond_to?("selection").should be_true
      Barometer::Base.selection.should == { 1 => [:wunderground] }
      Barometer::Base.selection = { 1 => [:yahoo] }
      Barometer::Base.selection.should == { 1 => [:yahoo] }
      Barometer.selection = @preference_hash
    end
    
    it "returns a Weather Service driver" do
      Barometer.source(:wunderground).should == Barometer::Wunderground
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
      query_term = "Calgary,AB"
      @barometer = Barometer::Base.new(query_term)
      @time = Time.now
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{CGI.escape(query_term)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'current_calgary_ab.xml')
        )
      )
      FakeWeb.register_uri(:get, 
        "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(query_term)}",
        :string => File.read(File.join(File.dirname(__FILE__), 
          'fixtures', 
          'forecast_calgary_ab.xml')
        )
      )
    end
    
    it "responds to measure" do
      @barometer.respond_to?("measure").should be_true
    end
    
    it "requires a Time (or nil)" do
      lambda { @barometer.measure(1) }.should raise_error(ArgumentError)
      @time.is_a?(Time).should be_true
      @barometer.measure
      lambda { @barometer.measure }.should_not raise_error(ArgumentError)
      lambda { @barometer.measure(@time) }.should_not raise_error(ArgumentError)
    end
      
    it "returns a Barometer::Weather object" do
      @barometer.measure.is_a?(Barometer::Weather).should be_true
    end
    
    it "raises RuntimeError if no services successful" do
      Barometer::Base.selection = { 1 => [] }
      lambda { @barometer.measure }.should raise_error(RuntimeError)
    end
    
  end

end
