require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Http::Get do
  describe ".call" do
    let(:url) { double(:url) }
    let(:params) { double(:params) }

    it "creates an Address" do
      Barometer::Http::Requester.stub(:get => nil)

      Barometer::Http::Address.should_receive(:new).with(url, params)

      Barometer::Http::Get.call(url, params)
    end

    it "calls Requester#get" do
      address = double(:address)
      Barometer::Http::Address.stub(:new => address)

      Barometer::Http::Requester.should_receive(:get).with(address)

      Barometer::Http::Get.call(url, params)
    end
  end
end
