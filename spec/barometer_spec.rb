require 'spec_helper'

describe Barometer do
  describe ".config" do
    around do |example|
      cached_config = Barometer.config
      example.run
      Barometer.config = cached_config
    end

    it "has a default value" do
      expect( Barometer.config ).to eq({ 1 => {wunderground: {version: :v1}} })
    end

    it "sets the value" do
      Barometer.config = { 1 => [:yahoo] }
      expect( Barometer.config ).to eq({ 1 => [:yahoo] })
    end
  end

  describe ".timeout" do
    around do |example|
      cached_timeout = Barometer.timeout
      example.run
      Barometer.timeout = cached_timeout
    end

    it "has a default value" do
      expect( Barometer.timeout ).to eq 15
    end

    it "sets the value" do
      Barometer.timeout = 5
      expect( Barometer.timeout ).to eq 5
    end
  end
end
