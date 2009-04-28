require 'spec_helper'

describe "Units" do
  
  describe "when initialized" do
    
    before(:each) do
      @units = Barometer::Units.new
    end
    
    it "responds to metric, defaults to true" do
      @units.metric.should be_true
    end
    
    it "allows metric to be set" do
      @units.metric.should be_true
      
      @units2 = Barometer::Units.new(false)
      @units2.metric.should be_false
    end
    
    it "stubs metric_default" do
      lambda { @units.metric_default = 5 }.should raise_error(NotImplementedError)
    end
    
    it "stubs imperial_default" do
      lambda { @units.imperial_default = 5 }.should raise_error(NotImplementedError)
    end
    
  end
  
  describe "changing units" do
    
    before(:each) do
      @units = Barometer::Units.new
    end
    
    it "indicates if metric?" do
      @units.metric.should be_true
      @units.metric?.should be_true
      @units.metric = false
      @units.metric.should be_false
      @units.metric?.should be_false
    end
    
    it "changes to imperial" do
      @units.metric?.should be_true
      @units.imperial!
      @units.metric?.should be_false
    end
    
    it "changes to metric" do
      @units.metric = false
      @units.metric?.should be_false
      @units.metric!
      @units.metric?.should be_true
    end

  end
  
  describe "when assigning values" do
    
    before(:each) do
      module Barometer
        class Units
          attr_accessor :a, :b
          def metric_default=(value)
            self.a = value
          end
          def imperial_default=(value)
            self.b = value
          end
        end
      end
      @units_metric = Barometer::Units.new(true)
      @units_imperial = Barometer::Units.new(false)
      @test_value_a = 5.5
      @test_value_b = 9.9
    end
    
    it "assigns metric_default" do
      @units_metric.metric?.should be_true
      @units_metric << @test_value_a
      @units_metric.a.should == @test_value_a
      
      @units_metric << [@test_value_b, @test_value_a]
      @units_metric.a.should == @test_value_b
    end
    
    it "assigns imperial_default" do
      @units_imperial.metric?.should be_false
      @units_imperial << @test_value_a
      @units_imperial.b.should == @test_value_a
      
      @units_imperial << [@test_value_a, @test_value_b]
      @units_imperial.b.should == @test_value_b
    end
    
  end

end