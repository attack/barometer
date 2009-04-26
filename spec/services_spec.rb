require 'spec_helper'

describe "Services" do
  
  before(:each) do
    query_term = "Calgary,AB"
    @query = Barometer::Query.new(query_term)
    @service = Barometer::Service.source(:wunderground)
    @time = Time.now
    FakeWeb.register_uri(:get, 
      "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{query_term}",
      :string => File.read(File.join(File.dirname(__FILE__), 
        'fixtures', 
        'current_calgary_ab.xml')
      )
    )
    FakeWeb.register_uri(:get, 
      "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{query_term}",
      :string => File.read(File.join(File.dirname(__FILE__), 
        'fixtures', 
        'forecast_calgary_ab.xml')
      )
    )
  end
  
  describe "and the class method" do
    
    describe "source" do
      
      it "responds" do
        Barometer::Service.respond_to?("source").should be_true
      end
      
      it "requires a Symbol or String" do
        lambda { Barometer::Service.source }.should raise_error(ArgumentError)
        lambda { Barometer::Service.source(1) }.should raise_error(ArgumentError)
        
        lambda { Barometer::Service.source("wunderground") }.should_not raise_error(ArgumentError)
        lambda { Barometer::Service.source(:wunderground) }.should_not raise_error(ArgumentError)
      end
      
      it "raises an error if source doesn't exist" do
        lambda { Barometer::Service.source(:not_valid) }.should raise_error(ArgumentError)
        lambda { Barometer::Service.source(:wunderground) }.should_not raise_error(ArgumentError)
      end
      
      it "returns the corresponding Service object" do
        Barometer::Service.source(:wunderground).should == Barometer::Wunderground
        Barometer::Service.source(:wunderground).superclass.should == Barometer::Service
      end
      
      it "raises an error when retrieving the wrong class" do
        lambda { Barometer::Service.source(:temperature) }.should raise_error(ArgumentError)
      end
      
    end
    
  end
  
  describe "when initialized" do
    
    before(:each) do
      @service = Barometer::Service.new
    end
    
    it "stubs _measure" do
      lambda { Barometer::Service._measure }.should raise_error(NotImplementedError)
    end
    
    it "stubs get_current" do
      lambda { Barometer::Service.get_current }.should raise_error(NotImplementedError)
    end
    
    it "stubs get_forecast" do
      lambda { Barometer::Service.get_forecast }.should raise_error(NotImplementedError)
    end
    
    it "stubs accepted_formats" do
      lambda { Barometer::Service.accepted_formats }.should raise_error(NotImplementedError)
    end
    
    it "defaults meets_requirements?" do
      Barometer::Service.meets_requirements?.should be_true
    end
    
    it "defaults supports_country?" do
      Barometer::Service.supports_country?.should be_true
    end
    
    it "defaults requires_keys?" do
      Barometer::Service.requires_keys?.should be_false
    end
    
    it "defaults has_keys?" do
      lambda { Barometer::Service.has_keys? }.should raise_error(NotImplementedError)
    end
    
  end
  
  describe "when measuring," do
    
    it "responds to measure" do
      Barometer::Service.respond_to?("measure").should be_true
    end
    
    # since Barometer::Service defines the measure method, you could actuall just
    # call Barometer::Service.measure ... but this will not invoke a specific
    # weather API driver.  Make sure this usage raises an error.
    it "requires an actuall driver" do
      lambda { Barometer::Service.measure(@query) }.should raise_error(NotImplementedError)
    end
    
    it "requires a Barometer::Query object" do
      lambda { Barometer::Service.measure("invalid") }.should raise_error(ArgumentError)
      @query.is_a?(Barometer::Query).should be_true
      lambda { Barometer::Service.measure(@query) }.should_not raise_error(ArgumentError)
    end
    
    it "returns a Barometer::Measurement object" do
      @service.measure(@query).is_a?(Barometer::Measurement).should be_true
    end
    
    it "returns current and future" do
      measurement = @service.measure(@query)
      measurement.current.is_a?(Barometer::CurrentMeasurement).should be_true
      measurement.forecast.is_a?(Array).should be_true
    end
    
  end
  
end