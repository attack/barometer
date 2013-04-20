require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Http::Post do
  describe ".call" do
    it "posts http content to a given address" do
      stub_request(:post, "www.example.com").to_return(:body => "Hello World")

      content = Barometer::Http::Post.call('www.example.com', :foo => :bar)
      content.should include('Hello World')
    end

    it "raises Barometer::TimeoutError when it times out" do
      stub_request(:post, "www.example.com").to_timeout

      expect {
        Barometer::Http::Post.call('www.example.com')
      }.to raise_error(Barometer::TimeoutError)
    end
  end
end
