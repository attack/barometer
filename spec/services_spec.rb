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
    
    it "stubs measure_current" do
      lambda { Barometer::Service.measure_current }.should raise_error(NotImplementedError)
    end
    
    it "stubs measure_forecast" do
      lambda { Barometer::Service.measure_forecast }.should raise_error(NotImplementedError)
    end
    
    it "stubs measure_all" do
      lambda { Barometer::Service.measure_all }.should raise_error(NotImplementedError)
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
    
    it "requires a Time object" do
      lambda { Barometer::Service.measure(@query, "invalid") }.should raise_error(ArgumentError)
      @time.is_a?(Time).should be_true
      lambda { Barometer::Service.measure(@query, @time) }.should_not raise_error(ArgumentError)
    end
    
    it "returns a Barometer::Measurement object" do
      @service.measure(@query).is_a?(Barometer::Measurement).should be_true
    end
    
    it "returns current and future when no time specified" do
      measurement = @service.measure(@query, nil)
      measurement.current.is_a?(Barometer::CurrentMeasurement).should be_true
      measurement.forecast.is_a?(Array).should be_true
    end
      
    it "measures current only when current (or within 10 minutes)" do
      measurement = @service.measure(@query, @time)
      measurement.current.is_a?(Barometer::CurrentMeasurement).should be_true
      measurement.forecast.is_a?(Array).should be_true
      
      measurement = @service.measure(@query, @time + (9 * 60))
      measurement.current.is_a?(Barometer::CurrentMeasurement).should be_true
      measurement.forecast.is_a?(Array).should be_true
    end
    
    # this test will fail if ran between 11:50pm and midnight
    it "measures all when time is still for today (but more then 10 minutes ahead)" do
      if (@time.hour >= 23 && @time.min >= 49)
        puts
        puts " --- NOTE ---"
        puts "Please re-run this after midnight"
        false.should be_true
      else  
        measurement = @service.measure(@query, @time + (11 * 60))
        measurement.current.is_a?(Barometer::CurrentMeasurement).should be_true
        measurement.forecast.is_a?(Array).should be_true
      end
    end
    
    it "measures forecast only when in the future (but not today still)" do
      measurement = @service.measure(@query, @time + (24 * 60 * 60))
      measurement.current.is_a?(Barometer::CurrentMeasurement).should be_true
      measurement.forecast.is_a?(Array).should be_true
    end
    
  end
  
end