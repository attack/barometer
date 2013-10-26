require_relative '../spec_helper'

describe Barometer::Utils::Time do
  describe ".parse" do
    it "accepts nil, does nothing" do
      time = Barometer::Utils::Time.parse
      time.should be_nil
    end

    it "parses a Time object" do
      t = Time.now.utc
      time = Barometer::Utils::Time.parse(t)

      assert_times_are_equal(time, t)
    end

    it "parses a DateTime object" do
      t = DateTime.now
      time = Barometer::Utils::Time.parse(t)

      assert_times_are_equal(time, ::Time.now)
    end

    it "calls to_time on object, if it can" do
      utc = Time.now.utc
      t = double(:foo, to_time: utc)
      time = Barometer::Utils::Time.parse(t)

      assert_times_are_equal(time, utc)
    end

    it "parses a String (with no format), assumes UTC" do
      t = "March 15, 10:36 AM 2013"

      time = Barometer::Utils::Time.parse(t)
      assert_times_are_equal(time, Time.utc(2013, 3, 15, 10, 36, 0))
    end

    it "parses a String (with optional format), assumes UTC" do
      format = "%B %e, %l:%M %p %Y"
      t = "March 15, 10:36 AM 2013"

      time = Barometer::Utils::Time.parse(t, format)
      assert_times_are_equal(time, Time.utc(2013, 3, 15, 10, 36, 0))
    end

    it "parses a timezoned String (with optional format)" do
      format = "%B %e, %l:%M %p %z %Y"
      t = "March 15, 10:36 AM -0800 2013"

      time = Barometer::Utils::Time.parse(t, format)
      assert_times_are_equal(time, Time.utc(2013, 3, 15, 18, 36, 0))
    end

    it "accepts an array of values, creating a UTC time" do
      time = Barometer::Utils::Time.parse(2013, 3, 15, 18, 36, 0)
      assert_times_are_equal(time, Time.utc(2013, 3, 15, 18, 36, 0))
    end
  end

  describe ".strptime" do
  end

  describe ".strftime" do
  end

  describe ".utc_from_base_plus_local_time" do
  end

  describe ".utc_merge_base_plus_time" do
  end

  describe ".add_one_day" do
  end

  describe ".add_one_hour" do
  end

  def assert_times_are_equal(t1, t2)
    if t1.to_i == t2.to_i
      expect( t1.to_i ).to eq t2.to_i
    else
      expect( t1.to_i ).to be_within(2).of(t2.to_i)
    end
  end
end
