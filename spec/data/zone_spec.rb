require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Data::Zone do

  # describe "and class methods" do
  #
  #   it "responds to now and returns Time object" do
  #     Barometer::Data::Zone.respond_to?("now").should be_true
  #     Barometer::Data::Zone.now.is_a?(Time).should be_true
  #   end
  #
  #   it "responds to today and returns Date object" do
  #     Barometer::Data::Zone.respond_to?("today").should be_true
  #     Barometer::Data::Zone.today.is_a?(Date).should be_true
  #   end
  #
  # end

  describe "when initialized" do

    describe "with a full zone" do

      before(:each) do
        @utc = Time.now.utc
        @timezone = "Europe/Paris"
        @zone = Barometer::Data::Zone.new(@timezone)
      end

      it "responds to zone_full" do
        @zone.zone_full.should_not be_nil
        @zone.zone_full.should == @timezone
      end

      it "responds to zone_code" do
        @zone.zone_code.should be_nil
      end

      it "responds to zone_offset" do
        @zone.zone_offset.should be_nil
      end

      it "responds to tz" do
        expect { Barometer::Data::Zone.new("invalid timezone") }.to raise_error(ArgumentError)

        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz.should_not be_nil
      end

      it "responds to full" do
        @zone.respond_to?("full").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.full.should == @timezone

        zone = Barometer::Data::Zone.new(@timezone)
        zone.full.should == @timezone
      end

      it "responds to code" do
        @zone.respond_to?("code").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.code.should be_nil

        zone = Barometer::Data::Zone.new(@timezone)
        # the expected result of this depends on the time of year
        # when summer expect "CEST", otherwise "CET"
        # just let TZINFO handle this
        zone.code.should == TZInfo::Timezone.get(@timezone).period_for_utc(Time.now.utc).zone_identifier.to_s
      end

      it "responds to dst?" do
        @zone.respond_to?("dst?").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.dst?.should be_nil
      end

      it "responds to now" do
        @zone.respond_to?("now").should be_true
        @zone.now.is_a?(Time).should be_true

        period = @zone.tz.period_for_utc(Time.now)
        actual_now = Time.now.utc + period.utc_total_offset

        now = @zone.now
        now.hour.should == actual_now.hour
        now.min.should == actual_now.min
        now.sec.should == actual_now.sec
        now.year.should == actual_now.year
        now.month.should == actual_now.month
        now.day.should == actual_now.day
      end

      it "responds to today" do
        @zone.respond_to?("today").should be_true
        @zone.today.is_a?(Date).should be_true

        period = @zone.tz.period_for_utc(Time.now)
        actual_now = Time.now.utc + period.utc_total_offset

        now = @zone.today
        now.year.should == actual_now.year
        now.month.should == actual_now.month
        now.day.should == actual_now.day
      end

      it "converts local_time to utc" do
        local_time = Time.now.utc
        utc_time = @zone.local_to_utc(local_time)

        offset =  @zone.tz.period_for_utc(local_time).utc_total_offset
        utc_time.should == (local_time - offset)
      end

      it "converts utc to local_time" do
        utc_time = Time.now.utc
        local_time = @zone.utc_to_local(utc_time)

        offset =  @zone.tz.period_for_utc(local_time).utc_total_offset
        utc_time.should == (local_time - offset)
      end

    end

    describe "with a zone code" do

      before(:each) do
        @utc = Time.now.utc
        @timezone = "EAST"
        @zone = Barometer::Data::Zone.new(@timezone)
      end

      it "responds to zone_code" do
        @zone.zone_code.should_not be_nil
        @zone.zone_code.should == @timezone
      end

      it "responds to zone_full" do
        @zone.zone_full.should be_nil
      end

      it "responds to zone_offset" do
        @zone.zone_offset.should be_nil
      end

      it "responds to tz" do
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz.should be_nil
      end

      it "responds to code" do
        @zone.respond_to?("code").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.code.should == @timezone

        zone = Barometer::Data::Zone.new(@timezone)
        zone.code.should == @timezone
      end

      it "responds to full" do
        @zone.respond_to?("full").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.full.should be_nil

        zone = Barometer::Data::Zone.new(@timezone)
        zone.full.should be_nil
      end

      it "responds to now" do
        @zone.respond_to?("now").should be_true
        @zone.now.is_a?(Time).should be_true

        actual_now = Time.now.utc + (-6*60*60)

        now = @zone.now
        now.hour.should == actual_now.hour
        now.min.should == actual_now.min
        now.sec.should == actual_now.sec
        now.year.should == actual_now.year
        now.month.should == actual_now.month
        now.day.should == actual_now.day
      end

      it "responds to today" do
        @zone.respond_to?("today").should be_true
        @zone.today.is_a?(Date).should be_true

        actual_now = Time.now.utc + (-6*60*60)

        now = @zone.today
        now.year.should == actual_now.year
        now.month.should == actual_now.month
        now.day.should == actual_now.day
      end

      it "converts local_time to utc" do
        local_time = Time.now.utc
        utc_time = @zone.local_to_utc(local_time)

        utc_time.year.should == (local_time - @zone.offset).year
        utc_time.month.should == (local_time - @zone.offset).month
        utc_time.day.should == (local_time - @zone.offset).day
        utc_time.hour.should == (local_time - @zone.offset).hour
        utc_time.min.should == (local_time - @zone.offset).min
        utc_time.sec.should == (local_time - @zone.offset).sec
      end

      it "converts utc to local_time" do
        utc_time = Time.now.utc
        local_time = @zone.utc_to_local(utc_time)

        local_time.year.should == (utc_time + @zone.offset).year
        local_time.month.should == (utc_time + @zone.offset).month
        local_time.day.should == (utc_time + @zone.offset).day
        local_time.hour.should == (utc_time + @zone.offset).hour
        local_time.min.should == (utc_time + @zone.offset).min
        local_time.sec.should == (utc_time + @zone.offset).sec
      end

    end

    describe "with a zone offset" do

      before(:each) do
        @utc = Time.now.utc
        @timezone = 8.5
        @zone = Barometer::Data::Zone.new(@timezone)
      end

      it "responds to zone_offset" do
        @zone.zone_offset.should_not be_nil
        @zone.zone_offset.should == @timezone
      end

      it "responds to zone_full" do
        @zone.zone_full.should be_nil
      end

      it "responds to zone_code" do
        @zone.zone_code.should be_nil
      end

      it "responds to tz" do
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz.should be_nil
      end

      it "responds to offset" do
        @zone.respond_to?("offset").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.offset.should == (@timezone * 60 * 60)

        zone = Barometer::Data::Zone.new(@timezone)
        zone.offset.should == (@timezone * 60 * 60)
      end

      it "responds to full" do
        @zone.respond_to?("full").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.full.should be_nil

        zone = Barometer::Data::Zone.new(@timezone)
        zone.full.should be_nil
      end

      it "responds to code" do
        @zone.respond_to?("code").should be_true
        zone = Barometer::Data::Zone.new(@timezone)
        zone.tz = nil
        zone.tz.should be_nil
        zone.code.should be_nil

        zone = Barometer::Data::Zone.new(@timezone)
        zone.code.should be_nil
      end

      it "responds to now" do
        @zone.respond_to?("now").should be_true
        @zone.now.is_a?(Time).should be_true

        actual_now = Time.now.utc + (@timezone.to_f*60*60)

        now = @zone.now
        now.hour.should == actual_now.hour
        now.min.should == actual_now.min
        now.sec.should == actual_now.sec
        now.year.should == actual_now.year
        now.month.should == actual_now.month
        now.day.should == actual_now.day
      end

      it "responds to today" do
        @zone.respond_to?("today").should be_true
        @zone.today.is_a?(Date).should be_true

        actual_now = Time.now.utc + (@timezone.to_f*60*60)

        now = @zone.today
        now.year.should == actual_now.year
        now.month.should == actual_now.month
        now.day.should == actual_now.day
      end

      it "converts local_time to utc" do
        local_time = Time.now.utc
        utc_time = @zone.local_to_utc(local_time)

        utc_time.year.should == (local_time - @zone.offset).year
        utc_time.month.should == (local_time - @zone.offset).month
        utc_time.day.should == (local_time - @zone.offset).day
        utc_time.hour.should == (local_time - @zone.offset).hour
        utc_time.min.should == (local_time - @zone.offset).min
        utc_time.sec.should == (local_time - @zone.offset).sec
      end

      it "converts utc to local_time" do
        utc_time = Time.now.utc
        local_time = @zone.utc_to_local(utc_time)

        local_time.year.should == (utc_time + @zone.offset).year
        local_time.month.should == (utc_time + @zone.offset).month
        local_time.day.should == (utc_time + @zone.offset).day
        local_time.hour.should == (utc_time + @zone.offset).hour
        local_time.min.should == (utc_time + @zone.offset).min
        local_time.sec.should == (utc_time + @zone.offset).sec
      end

    end

  end

  describe "when detecting zones" do

    it "recognozes a full time zone format" do
      Barometer::Data::Zone.is_zone_full?("invalid").should be_false
      Barometer::Data::Zone.is_zone_full?("America/New York").should be_true
    end

    it "matches a zone offset" do
      Barometer::Data::Zone.is_zone_offset?("invalid").should be_false
      Barometer::Data::Zone.is_zone_offset?("MST").should be_false
      Barometer::Data::Zone.is_zone_offset?("10").should be_false
      Barometer::Data::Zone.is_zone_offset?(-10).should be_true
    end

    it "matches a zone code" do
      Barometer::Data::Zone.is_zone_code?("invalid").should be_false
      Barometer::Data::Zone.is_zone_code?("MST").should be_true
      Barometer::Data::Zone.is_zone_code?("EAST").should be_true
    end

  end

end
