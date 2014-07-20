require_relative '../spec_helper'

RSpec.describe Barometer::Utils::Address do
  describe "#url" do
    it "returns the initialized url" do
      address = Barometer::Utils::Address.new("http://www.example.com")
      expect(address.url).to eq "http://www.example.com"
    end

    it "ignores query params in the url" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar")
      expect(address.url).to eq "http://www.example.com"
    end

    it "ignores query params in the url" do
      address = Barometer::Utils::Address.new("http://www.example.com", foo: :bar)
      expect(address.url).to eq "http://www.example.com"
    end
  end

  describe "#query" do
    it "returns the initialized query" do
      address = Barometer::Utils::Address.new("", {"foo" => "bar"})
      expect(address.query).to eq({"foo" => "bar"})
    end

    it "returns the extracted query" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar")
      expect(address.query).to eq({"foo" => "bar"})
    end

    it "combines the extracted query and the provided query" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar", foz: :baz)
      expect(address.query).to eq({"foo" => "bar", "foz" => "baz"})
    end

    it "converts all keys to String" do
      address = Barometer::Utils::Address.new("", {foo: :bar})
      expect(address.query).to eq({"foo" => "bar"})
    end
  end

  describe "#add" do
    it "merges query params with existing params" do
      address = Barometer::Utils::Address.new("", {"foo" => "bar"})
      address.add(foz: :baz)
      expect(address.query).to eq({"foo" => "bar", "foz" => "baz"})
    end
  end

  describe "#to_s" do
    it "formats the query params with the url" do
      address = Barometer::Utils::Address.new("http://www.example.com", foo: :bar)
      expect(address.to_s).to eq "http://www.example.com?foo=bar"
    end

    it "formats the query params with the url" do
      address = Barometer::Utils::Address.new("http://www.example.com?foo=bar", foz: :baz)
      expect(address.to_s).to eq "http://www.example.com?foo=bar&foz=baz"
    end

    it "formats just the url" do
      address = Barometer::Utils::Address.new("http://www.example.com")
      expect(address.to_s).to eq "http://www.example.com"
    end
  end
end
