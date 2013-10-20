require_relative '../spec_helper'
require 'time'

module Barometer::Response
  describe Base do
    let(:query) { build_query }
    let(:response) { Base.new }

    specify { expect( response ).to have_field(:query).of_type(String) }
    specify { expect( response ).to have_field(:weight).of_type(Integer) }
    specify { expect( response ).to have_field(:status_code).of_type(Integer) }

    describe ".new" do
      specify { expect( response.weight ).to eq 1 }
      specify { expect( response.requested_at ).to be }
    end

    describe "#success?" do
      it "returns true if :status_code == 200" do
        response.status_code = 200
        expect( response ).to be_success
      end

      it "returns false if :status_code does not == 200" do
        response.status_code = nil
        expect( response ).not_to be_success

        response.status_code = 406
        expect( response ).not_to be_success
      end
    end

    describe "#complete?" do
      before { response.current = Current.new }

      it "returns true when current is complete" do
        response.current.stub(complete?: true)
        expect( response ).to be_complete
      end

      it "returns false when the is no current" do
        response.current = nil
        expect( response ).not_to be_complete
      end

      it "returns false when current is not complete" do
        response.current.stub(complete?: false)
        expect( response ).not_to be_complete
      end
    end

    describe "#for" do
      let(:date) { double(:date) }
      let(:prediction_collection) { double(:prediction_collection) }

      before do
        prediction_collection.stub(:for)
        response.forecast = prediction_collection
      end

      context "when a date is given" do
        it "passes it along to the collection" do
          response.for(date)
          expect( response.forecast ).to have_received(:for).with(date)
        end
      end

      context "when a date is not given" do
        context "and the timezone is set" do
          it "passes along timezone.today to the collection" do
            timezone = Barometer::Data::Zone.new('EST')
            timezone.stub(today: date)
            response.timezone = timezone

            response.for

            expect( response.forecast ).to have_received(:for).with(date)
          end
        end

        context "and the tiemzone is not set" do
          it "passes along Date.today to the collection" do
            Date.stub(today: date)
            response.timezone = nil

            response.for

            expect( response.forecast ).to have_received(:for).with(date)
          end
        end
      end
    end

    describe "#add_query" do
      let(:query) { double(:query, to_s: 'foo', format: :unknown, metric?: true) }
      before { response.add_query(query) }

      specify { expect( response ).to be_metric }
      specify { expect( response.format ).to eq :unknown }
      specify { expect( response.query ).to eq 'foo' }
    end
  end
end
