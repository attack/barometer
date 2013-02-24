require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Data::Geo do
  describe "#new" do
    its(:query) { should be_nil }
    its(:latitude) { should be_nil }
    its(:longitude) { should be_nil }
    its(:country_code) { should be_nil }
    its(:locality) { should be_nil }
    its(:region) { should be_nil }
    its(:country) { should be_nil }
    its(:address) { should be_nil }

    it "raises an error when not given a Hash" do
      expect {
        Data::Geo.new(1)
      }.to raise_error(ArgumentError)
    end

    it "returns a Barometer::Geo object" do
      subject = Data::Geo.new(Hash.new)
      subject.is_a?(Data::Geo).should be_true
    end
  end

  describe "#coordinates" do
    it "joins latitude and longitude" do
      subject.longitude = "99.99"
      subject.latitude = "88.88"
      subject.coordinates.should == "88.88,99.99"
    end
  end

  describe "#to_s" do
    it "defaults to blank" do
      subject.to_s.should == ""
    end

    it "should print a string" do
      subject.address = "address"
      subject.to_s.should == "address"
      subject.locality = "locality"
      subject.to_s.should == "address, locality"
      subject.country_code = "code"
      subject.to_s.should == "address, locality, code"
    end
  end

  describe "#build_from_hash" do
    it "raises an error with invalid input" do
      expect {
        subject.build_from_hash(1)
      }.to raise_error(ArgumentError)
    end

    it "accepts no arguements" do
      expect {
        subject.build_from_hash
      }.not_to raise_error(ArgumentError)
    end

    it "accepts HTTParty::Response object" do
      expect {
        subject.build_from_hash(Hash.new)
      }.not_to raise_error(ArgumentError)
    end
  end
end
