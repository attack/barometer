require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Data::Location do
  describe "#new" do
    its(:id) { should be_nil }
    its(:name) { should be_nil }
    its(:city) { should be_nil }
    its(:state_name) { should be_nil }
    its(:state_code) { should be_nil }
    its(:country) { should be_nil }
    its(:country_code) { should be_nil }
    its(:zip_code) { should be_nil }
    its(:latitude) { should be_nil }
    its(:longitude) { should be_nil }
  end

  describe "#coordinates" do
    it "joins  longitude and latitude" do
      subject.longitude = "99.99"
      subject.latitude = "88.88"
      subject.coordinates.should == "88.88,99.99"
    end
  end

  describe "#nil?" do
    it "true if nothing is set" do
      subject.nil?.should be_true
    end

    it "returns false if anything is set" do
      subject.name = "name"
      subject.nil?.should be_false
    end
  end

  describe "#to_s" do
    it "defaults to an empty string" do
      subject.to_s.should == ""
    end

    it "compiles a string" do
      subject.name = "name"
      subject.to_s.should == "name"

      subject.city = "city"
      subject.to_s.should == "name, city"

      subject.country_code = "country_code"
      subject.to_s.should == "name, city, country_code"

      subject.country = "country"
      subject.to_s.should == "name, city, country"

      subject.state_code = "state_code"
      subject.to_s.should == "name, city, state_code, country"

      subject.state_name = "state_name"
      subject.to_s.should == "name, city, state_name, country"
    end
  end
end
