require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Utils::Get do
  describe ".call" do
    it "gets http content from a given address" do
      stub_request(:get, "www.example.com?foo=bar").to_return(body: "Hello World")

      content = Barometer::Utils::Get.call('www.example.com', foo: :bar)
      content.should include('Hello World')
    end

    it "raises Barometer::TimeoutError when it times out" do
      stub_request(:get, "www.example.com").to_timeout

      expect {
        Barometer::Utils::Get.call('www.example.com')
      }.to raise_error(Barometer::TimeoutError)
    end
  end
end
