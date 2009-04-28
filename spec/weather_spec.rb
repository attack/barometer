require 'spec_helper'

describe "Weather" do
  
  describe "when initialized" do
    
    before(:each) do
      @weather = Barometer::Weather.new
    end

    it "responds to measurements (and sets default value)" do
      @weather.measurements.should == []
    end

    it "responds to current" do
      @weather.respond_to?("current").should be_true
    end

    it "responds to forecast" do
      @weather.respond_to?("forecast").should be_true
    end

    it "responds to today" do
      @weather.respond_to?("today").should be_true
    end

    it "responds to tommorrow" do
      @weather.respond_to?("tomorrow").should be_true
    end

    it "responds to for" do
      
      @weather.respond_to?("for").should be_true
    end

  end
  
  describe "with measurements" do
    
    before(:each) do
      module Barometer
        class Measurement
          attr_accessor :success
        end
      end
      @weather = Barometer::Weather.new
      @wunderground = Barometer::Measurement.new(:wunderground)
      @wunderground.success = true
      @yahoo = Barometer::Measurement.new(:yahoo)
      @yahoo.success = true
      @google = Barometer::Measurement.new(:google)
      @weather.measurements << @wunderground
      @weather.measurements << @yahoo
      @weather.measurements << @google
    end
    
    it "retrieves a source measurement" do
      lambda { @weather.source(1) }.should raise_error(ArgumentError)
      lambda { @weather.source("valid") }.should_not raise_error(ArgumentError)
      lambda { @weather.source(:valid) }.should_not raise_error(ArgumentError)
      @weather.source(:does_not_exist).should be_nil
      @weather.source(:wunderground).should == @wunderground
    end
    
    it "lists the sources of measurements (that were successful)" do
      sources = @weather.sources
      sources.should_not be_nil
      @wunderground.success?.should be_true
      sources.include?(:wunderground).should be_true
      @yahoo.success?.should be_true
      sources.include?(:yahoo).should be_true
      @google.success?.should be_false
      sources.include?(:google).should be_false
    end
    
    it "returns the default source" do
      @weather.default.should == @wunderground
    end
    
  end
  
end