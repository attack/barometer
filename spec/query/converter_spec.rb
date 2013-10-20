require_relative '../spec_helper'

describe Barometer::Query::Converter do
  def clear_converters
    @converters_cache = Barometer::Query::Converter.converters
    Barometer::Query::Converter.converters = {}
  end

  def reset_conveters
    Barometer::Query::Converter.converters = @converters_cache
  end

  describe ".register" do
    before { clear_converters }
    after { reset_conveters }

    context "when a 1:1 converter is registered" do
      it "makes the converter available" do
        zipcode_converter = double(:converter, from: [:short_zipcode])
        Barometer::Query::Converter.register(:zipcode, zipcode_converter)
        Barometer::Query::Converter.find(:short_zipcode, :zipcode).should == {zipcode: zipcode_converter}
      end
    end

    context "when a 2:1 converter is registered" do
      it "makes the converter available to each format" do
        coordinates_converter = double(:converter, from: [:short_zipcode, :zipcode])
        Barometer::Query::Converter.register(:coordinates, coordinates_converter)
        Barometer::Query::Converter.find(:short_zipcode, :coordinates).should == {coordinates: coordinates_converter}
        Barometer::Query::Converter.find(:zipcode, :coordinates).should == {coordinates: coordinates_converter}
      end
    end
  end

  describe ".find_all" do
    before { clear_converters }
    after { reset_conveters }

    context "when the conversion can be made directly" do
      it "returns the one converter" do
        coordinates_converter = double(:coordinates_converter, from: [:short_zipcode])
        Barometer::Query::Converter.register(:coordinates, coordinates_converter)

        converters = Barometer::Query::Converter.find_all(:short_zipcode, :coordinates)
        converters.should == [{coordinates: coordinates_converter}]
      end

      it "respects preference" do
        zipcode_converter = double(:zipcode_converter, from: [:short_zipcode])
        Barometer::Query::Converter.register(:zipcode, zipcode_converter)

        coordinates_converter = double(:coordinates_converter, from: [:short_zipcode])
        Barometer::Query::Converter.register(:coordinates, coordinates_converter)

        converters = Barometer::Query::Converter.find_all(:short_zipcode, [:foo, :coordinates, :zipcode])
        converters.should == [{coordinates: coordinates_converter}]
      end
    end

    context "when the conversion can only be made indirecty" do
      it "returns multiple converters" do
        coordinates_converter = double(:coordinates_converter, from: [:geocode])
        Barometer::Query::Converter.register(:coordinates, coordinates_converter)

        geocode_converter = double(:geocode_converter, from: [:short_zipcode])
        Barometer::Query::Converter.register(:geocode, geocode_converter)

        converters = Barometer::Query::Converter.find_all(:short_zipcode, :coordinates)
        converters.should == [
          {geocode: geocode_converter}, {coordinates: coordinates_converter}
        ]
      end

      it "respects preference" do
        zipcode_converter = double(:zipcode_converter, from: [:geocode])
        Barometer::Query::Converter.register(:zipcode, zipcode_converter)

        coordinates_converter = double(:coordinates_converter, from: [:geocode])
        Barometer::Query::Converter.register(:coordinates, coordinates_converter)

        geocode_converter = double(:geocode_converter, from: [:short_zipcode])
        Barometer::Query::Converter.register(:geocode, geocode_converter)

        converters = Barometer::Query::Converter.find_all(:short_zipcode, [:foo, :coordinates, :zipcode])
        converters.should == [
          {geocode: geocode_converter}, {coordinates: coordinates_converter}
        ]
      end
    end

    context "when the conversion cannot be made" do
      it "returns nil" do
        converters = Barometer::Query::Converter.find_all(:short_zipcode, :foo)
        converters.should be_empty
      end
    end
  end
end
