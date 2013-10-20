require_relative '../spec_helper'

describe Barometer::Utils::Address do
  describe "#url" do
    it "returns the initialized url" do
      address = Barometer::Utils::Address.new("http://www.example.com")
      address.url.should == "http://www.example.com"
    end

    it "ignores query params in the url" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar")
      address.url.should == "http://www.example.com"
    end

    it "ignores query params in the url" do
      address = Barometer::Utils::Address.new("http://www.example.com", foo: :bar)
      address.url.should == "http://www.example.com"
    end
  end

  describe "#query" do
    it "returns the initialized query" do
      address = Barometer::Utils::Address.new("", {"foo" => "bar"})
      address.query.should == {"foo" => "bar"}
    end

    it "returns the extracted query" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar")
      address.query.should == {"foo" => "bar"}
    end

    it "combines the extracted query and the provided query" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar", foz: :baz)
      address.query.should == {"foo" => "bar", "foz" => "baz"}
    end

    it "converts all keys to String" do
      address = Barometer::Utils::Address.new("", {foo: :bar})
      address.query.should == {"foo" => "bar"}
    end
  end

  describe "#add" do
    it "merges query params with existing params" do
      address = Barometer::Utils::Address.new("", {"foo" => "bar"})
      address.add(foz: :baz)
      address.query.should == {"foo" => "bar", "foz" => "baz"}
    end
  end

  describe "#to_s" do
    it "formats the query params with the url" do
      address = Barometer::Utils::Address.new("http://www.example.com", foo: :bar)
      address.to_s.should == "http://www.example.com?foo=bar"
    end

    it "formats the query params with the url" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar", foz: :baz)
      address.to_s.should == "http://www.example.com?foo=bar&foz=baz"
    end

    it "formats just the url" do
      address = Barometer::Utils::Address.new("http://www.example.com")
      address.to_s.should == "http://www.example.com"
    end
  end
end
