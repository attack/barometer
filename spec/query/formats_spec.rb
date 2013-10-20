require_relative '../spec_helper'

describe Barometer::Query::Format do
  def clear_formats
    @formats_cache = Barometer::Query::Format.formats
    Barometer::Query::Format.formats = []
  end

  def reset_formats
    Barometer::Query::Format.formats = @formats_cache
  end

  describe ".register" do
    before { clear_formats }
    after { reset_formats }

    it "adds the query format to the list of available formats" do
      expect {
        Barometer::Query::Format.register(:test_format, double(:format))
      }.to change { Barometer::Query::Format.formats.count }.by(1)
    end

    it "raises an error if no format class given" do
      expect {
        Barometer::Query::Format.register(:test_format)
      }.to raise_error(ArgumentError)
    end

    it "only registers a key once" do
      format = double(:format)
      Barometer::Query::Format.register(:test_format, format)
      expect {
        Barometer::Query::Format.register(:test_format, format)
      }.not_to change { Barometer::Query::Format.formats.count }
    end
  end

  describe ".find" do
    before { clear_formats }
    after { reset_formats }

    it "returns a registered format" do
      test_format = double(:test_format)
      Barometer::Query::Format.register(:test_format, test_format)

      Barometer::Query::Format.find(:test_format).should == test_format
    end

    it "raises an error if the format does not exist" do
      expect {
        Barometer::Query::Format.find(:test_format)
      }.to raise_error(Barometer::Query::Format::NotFound)
    end
  end
end
