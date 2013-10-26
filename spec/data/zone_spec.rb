require_relative '../spec_helper'

module Barometer::Data
  describe Zone do
    describe '#new' do
      let(:zone) { double(:zone) }

      before do
        ZoneFull.stub(detect?: false)
        ZoneOffset.stub(detect?: false)
        ZoneCode.stub(detect?: false)
      end

      it 'detects a full timezone input' do
        ZoneFull.stub(detect?: true, new: nil)
        Zone.new(zone)
        expect( ZoneFull ).to have_received(:new).with(zone)
      end

      it 'detects a timezone code input' do
        ZoneOffset.stub(detect?: true, new: nil)
        Zone.new(zone)
        expect( ZoneOffset ).to have_received(:new).with(zone)
      end

      it 'detects a timezone offset input' do
        ZoneCode.stub(detect?: true, new: nil)
        Zone.new(zone)
        expect( ZoneCode ).to have_received(:new).with(zone)
      end

      it 'raises an error when nothing detected' do
        expect {
          Zone.new(zone)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe ZoneFull do
    def stub_time(utc_now)
      now = double(:now, utc: utc_now)
      double(:time_class, now: now)
    end

    describe '.detect?' do
      it 'returns true when given a full timezone' do
        expect( ZoneFull.detect?('America/Los_Angeles') ).to be_true
      end

      it 'returns false when given a timezone code' do
        expect( ZoneFull.detect?('PST') ).to be_false
      end

      it 'returns false when given an offset' do
        expect( ZoneFull.detect?(10) ).to be_false
      end

      it 'returns false when given nothing' do
        expect( ZoneFull.detect?('') ).to be_false
        expect( ZoneFull.detect?(nil) ).to be_false
      end
    end

    describe '#code' do
      it 'returns the correct non-DST zone code' do
        time = stub_time(::Time.utc(2013, 1, 1))
        zone = ZoneFull.new('America/Los_Angeles', time)

        expect( zone.code ).to eq 'PST'
      end

      it 'returns the correct DST zone code' do
        time = stub_time(::Time.utc(2013, 6, 1))
        zone = ZoneFull.new('America/Los_Angeles', time)

        expect( zone.code ).to eq 'PDT'
      end
    end

    describe '#offset' do
      it 'returns the current non-DST offset' do
        time = stub_time(::Time.utc(2013, 1, 1, 18, 0, 0))
        zone = ZoneFull.new('America/Los_Angeles', time)

        expect( zone.offset ).to eq(-8 * 60 * 60)
      end

      it 'returns the current DST offset' do
        time = stub_time(::Time.utc(2013, 6, 1, 18, 0, 0))
        zone = ZoneFull.new('America/Los_Angeles', time)

        expect( zone.offset ).to eq(-7 * 60 * 60)
      end
    end

    describe '#now' do
      it 'returns the current non-DST local time' do
        time = stub_time(::Time.utc(2013, 1, 1, 18, 0, 0))
        zone = ZoneFull.new('America/Los_Angeles', time)

        expect( zone.now ).to eq ::Time.utc(2013, 1, 1, 10, 0, 0)
      end

      it 'returns the current DST local time' do
        time = stub_time(::Time.utc(2013, 6, 1, 18, 0, 0))
        zone = ZoneFull.new('America/Los_Angeles', time)

        expect( zone.now ).to eq ::Time.utc(2013, 6, 1, 11, 0, 0)
      end
    end

    describe '#to_s' do
      it 'returns the input zone' do
        expect( ZoneFull.new('Europe/Paris').to_s ).to eq 'Europe/Paris'
      end
    end

    describe '#local_to_utc' do
      it 'converts a time in the local time zone to UTC' do
        zone = ZoneFull.new('America/Los_Angeles')
        local_time = ::Time.now.utc

        expect( zone.local_to_utc(local_time).to_i ).to eq((local_time - zone.offset).to_i)
      end
    end

    describe '#utc_to_local' do
      it 'converts a time in the local time zone to UTC' do
        zone = ZoneFull.new('America/Los_Angeles')
        utc_time = ::Time.now.utc

        expect( zone.utc_to_local(utc_time).to_i ).to eq((utc_time + zone.offset).to_i)
      end
    end
  end

  describe ZoneOffset do
    def stub_time(utc_now)
      now = double(:now, utc: utc_now)
      double(:time_class, now: now)
    end

    describe '.detect?' do
      it 'returns false when given a full timezone' do
        expect( ZoneOffset.detect?('America/Los_Angeles') ).to be_false
      end

      it 'returns false when given a timezone code' do
        expect( ZoneOffset.detect?('PST') ).to be_false
      end

      it 'returns true when given an offset' do
        expect( ZoneOffset.detect?(10) ).to be_true
      end

      it 'returns false when given an offset out of range' do
        expect( ZoneOffset.detect?(15) ).to be_false
      end

      it 'returns false when given nothing' do
        expect( ZoneOffset.detect?('') ).to be_false
        expect( ZoneOffset.detect?(nil) ).to be_false
      end
    end

    describe '#code' do
      it 'returns nil' do
        expect( ZoneOffset.new(10).code ).to be_nil
      end
    end

    describe '#offset' do
      it 'converts the input from hours to seconds' do
        expect( ZoneOffset.new(5).offset ).to eq(5 * 60 * 60)
      end
    end

    describe '#now' do
      it 'returns the current local time' do
        time = stub_time(::Time.utc(2013, 1, 1, 10, 0, 0))
        zone = ZoneOffset.new(5, time)

        expect( zone.now ).to eq ::Time.utc(2013, 1, 1, 15, 0, 0)
      end
    end

    describe '#to_s' do
      it 'returns the input zone' do
        expect( ZoneOffset.new(5).to_s ).to eq '5'
      end
    end

    describe '#local_to_utc' do
      it 'converts a time in the local time zone to UTC' do
        zone = ZoneOffset.new(5)
        local_time = ::Time.now.utc

        expect( zone.local_to_utc(local_time).to_i ).to eq((local_time - zone.offset).to_i)
      end
    end

    describe '#utc_to_local' do
      it 'converts a time in the local time zone to UTC' do
        zone = ZoneOffset.new(5)
        utc_time = ::Time.now.utc

        expect( zone.utc_to_local(utc_time).to_i ).to eq((utc_time + zone.offset).to_i)
      end
    end
  end

  describe ZoneCode do
    def stub_time(utc_now)
      now = double(:now, utc: utc_now)
      double(:time_class, now: now)
    end

    describe '.detect?' do
      it 'returns false when given a full timezone' do
        expect( ZoneCode.detect?('America/Los_Angeles') ).to be_false
      end

      it 'returns true when given a timezone code' do
        expect( ZoneCode.detect?('PST') ).to be_true
      end

      it 'returns true when given an obscure timezone code' do
        expect( ZoneCode.detect?('CEST') ).to be_true
      end

      it 'returns false when given an invalid timezone code' do
        expect( ZoneCode.detect?('ABC') ).to be_false
      end

      it 'returns false when given an offset' do
        expect( ZoneCode.detect?(10) ).to be_false
      end

      it 'returns false when given nothing' do
        expect( ZoneCode.detect?('') ).to be_false
        expect( ZoneCode.detect?(nil) ).to be_false
      end
    end

    describe '#code' do
      it 'returns the input code' do
        expect( ZoneCode.new('PST').code ).to eq 'PST'
      end
    end

    describe '#offset' do
      it 'returns the offset in seconds' do
        expect( ZoneCode.new('PST').offset ).to eq(-8 * 60 * 60)
      end

      it 'returns the offset in seconds for an obscure input code' do
        expect( ZoneCode.new('CEST').offset ).to eq(2 * 60 * 60)
      end

      it 'returns 0 for unknown codes' do
        expect( ZoneCode.new('ABC').offset ).to be_zero
      end
    end

    describe '#now' do
      it 'returns the current local time' do
        time = stub_time(::Time.utc(2013, 1, 1, 10, 0, 0))
        zone = ZoneCode.new('PST', time)

        expect( zone.now ).to eq ::Time.utc(2013, 1, 1, 2, 0, 0)
      end
    end

    describe '#to_s' do
      it 'returns the input zone' do
        expect( ZoneCode.new('PST').to_s ).to eq 'PST'
      end
    end

    describe '#local_to_utc' do
      it 'converts a time in the local time zone to UTC' do
        zone = ZoneCode.new('PST')
        local_time = ::Time.now.utc

        expect( zone.local_to_utc(local_time).to_i ).to eq((local_time - zone.offset).to_i)
      end
    end

    describe '#utc_to_local' do
      it 'converts a time in the local time zone to UTC' do
        zone = ZoneCode.new('PST')
        utc_time = ::Time.now.utc

        expect( zone.utc_to_local(utc_time).to_i ).to eq((utc_time + zone.offset).to_i)
      end
    end
  end
end
