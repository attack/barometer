require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Http::Requester do
  describe ".get" do
    it "gets http content from a given address" do
      stub_request(:get, "www.example.com?foo=bar").to_return(:body => "Hello World")

      address = Barometer::Http::Address.new('www.example.com', :foo => :bar)
      content = Barometer::Http::Requester.get(address)

      content.should include('Hello World')
    end

    it "raises Barometer::TimeoutError when it times out" do
      stub_request(:get, "www.example.com").to_timeout

      expect {
        address = Barometer::Http::Address.new('www.example.com')
        Barometer::Http::Requester.get(address)
      }.to raise_error(Barometer::TimeoutError)
    end
  end
end
