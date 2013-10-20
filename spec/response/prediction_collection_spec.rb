require_relative '../spec_helper'

module Barometer::Response
  describe PredictionCollection do
    let(:prediction_collection) { PredictionCollection.new }

    describe "#<<" do
      it "adds Prediction" do
        expect {
          prediction_collection << Prediction.new
        }.to change{ prediction_collection.count }.by(1)
      end
    end

    describe "#[]" do
      let(:prediction) { Prediction.new }
      before { prediction_collection << prediction }

      it "finds prediction by index when passed a number" do
        expect( prediction_collection[0] ).to eq prediction
      end

      it "finds prediction by using #for when not passed a number" do
        index = double(:index)
        prediction_collection.stub(:for)

        prediction_collection[index]

        expect( prediction_collection ).to have_received(:for).with(index)
      end
    end

    describe "#for" do
      let(:tommorrow) { Date.today + 1 }

      context "when there are no predictions" do
        specify { expect( prediction_collection.for(tommorrow) ).to be_nil }
      end

      context "when there are predictions" do
        before do
          today = Date.today

          0.upto(3) do |i|
            prediction = Prediction.new
            prediction.date = today + i
            prediction_collection << prediction
          end
        end

        it "finds the date using a String" do
          expect( prediction_collection.for(tommorrow.to_s) ).to eq prediction_collection[1]
        end

        it "finds the date using a Date" do
          expect( prediction_collection.for(tommorrow) ).to eq prediction_collection[1]
        end

        it "finds the date using a DateTime" do
          # 1.8.7 - Date does not have to_datetime
          datetime = DateTime.new(tommorrow.year, tommorrow.month, tommorrow.day)
          expect( prediction_collection.for(datetime) ).to eq prediction_collection[1]
        end

        it "finds the date using a Time" do
          # 1.8.7 - Date does not have to_time
          time = Time.parse(tommorrow.to_s)
          expect( prediction_collection.for(time) ).to eq prediction_collection[1]
        end

        it "finds the date using Data::Time" do
          time = Barometer::Utils::Time.parse(tommorrow.to_s)
          expect( prediction_collection.for(time) ).to eq prediction_collection[1]
        end

        it "finds nothing when there is not a match" do
          expect( prediction_collection.for(Date.today - 1) ).to be_nil
        end
      end
    end

    describe "#build" do
      it "yields a new response" do
        expect { |b|
          prediction_collection.build(&b)
        }.to yield_with_args(Prediction)
      end

      it "adds the new response to forecast array" do
        expect {
          prediction_collection.build do
          end
        }.to change{ prediction_collection.count }.by(1)
      end
    end
  end
end
