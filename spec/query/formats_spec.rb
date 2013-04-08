require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Formats do
  def clear_formats
    @formats_cache = Barometer::Formats.formats
    Barometer::Formats.formats = []
  end

  def reset_formats
    Barometer::Formats.formats = @formats_cache
  end

  describe ".register" do
    before { clear_formats }
    after { reset_formats }

    it "adds the query format to the list of available formats" do
      expect {
        Barometer::Formats.register(:test_format, double(:format))
      }.to change { Barometer::Formats.formats.count }.by(1)
    end

    it "raises an error if no format class given" do
      expect {
        Barometer::Formats.register(:test_format)
      }.to raise_error(ArgumentError)
    end

    it "only registers a key once" do
      format = double(:format)
      Barometer::Formats.register(:test_format, format)
      expect {
        Barometer::Formats.register(:test_format, format)
      }.not_to change { Barometer::Formats.formats.count }
    end
  end

  describe ".find" do
    before { clear_formats }
    after { reset_formats }

    it "returns a registered format" do
      test_format = double(:test_format)
      Barometer::Formats.register(:test_format, test_format)

      Barometer::Formats.find(:test_format).should == test_format
    end

    it "raises an error if the format does not exist" do
      expect {
        Barometer::Formats.find(:test_format)
      }.to raise_error(Barometer::Formats::NotFound)
    end
  end
end
