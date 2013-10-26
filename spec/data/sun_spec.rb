require_relative '../spec_helper'

module Barometer::Data
  describe Sun do
    let(:local_time_set) { Time.now + (60*60*8) }
    let(:local_time_rise) { Time.now }

    describe '#nil?' do
      it 'returns true if nothing is set' do
        sun = Sun.new(rise: nil, set: nil)
        expect( sun ).to be_nil
      end

      it 'returns false if sunrise is set' do
        sun = Sun.new(rise: local_time_rise, set: nil)
        expect( sun ).not_to be_nil
      end

      it 'returns false if sunset is set' do
        sun = Sun.new(rise: nil, set: local_time_set)
        expect( sun ).not_to be_nil
      end
    end

    describe 'comparisons' do
      let(:now) { Time.local(2009,5,5,11,40,00) }
      let(:early_time) { now - (60*60*8) }
      let(:mid_time) { now }
      let(:late_time) { now + (60*60*8) }

      describe '#after_rise?' do
        it 'returns true when after sun rise' do
          sun = Sun.new(rise: early_time, set: late_time)
          expect( sun.after_rise?(mid_time) ).to be_true
        end

        it 'returns false when before sun rise' do
          sun = Sun.new(rise: mid_time, set: late_time)
          expect( sun.after_rise?(early_time) ).to be_false
        end
      end

      describe '#before_set?' do
        it 'returns true when before sun set' do
          sun = Sun.new(rise: early_time, set: late_time)
          expect( sun.before_set?(mid_time) ).to be_true
        end

        it 'returns false when before sun set' do
          sun = Sun.new(rise: early_time, set: mid_time)
          expect( sun.before_set?(late_time) ).to be_false
        end
      end
    end

    describe '#to_s' do
      it 'defaults as blank' do
        sun = Sun.new()
        expect( sun.to_s ).to be_blank
      end

      it 'returns the sunrise time' do
        sun = Sun.new(rise: local_time_rise)
        expect( sun.to_s ).to eq "rise: #{local_time_rise.strftime('%H:%M')}"
      end

      it 'returns the sunset time' do
        sun = Sun.new(rise: nil, set: local_time_set)
        expect( sun.to_s ).to eq "set: #{local_time_set.strftime('%H:%M')}"
      end

      it 'returns both times' do
        sun = Sun.new(rise: local_time_rise, set: local_time_set)
        expect( sun.to_s ).to eq "rise: #{local_time_rise.strftime('%H:%M')}, set: #{local_time_set.strftime('%H:%M')}"
      end
    end
  end
end
