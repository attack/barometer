require_relative '../spec_helper'

module Barometer::Data
  class TestData < ConvertableUnits
    private

    def convert_imperial_to_metric(imperial_value)
      imperial_value*200
    end

    def convert_metric_to_imperial(metric_value)
      metric_value/200
    end
  end

  describe ConvertableUnits do
    describe '.initialize' do
      it 'sets metric value' do
        test_data = TestData.new(200.0, nil)
        expect( test_data.metric ).to eq 200.0
      end

      it 'sets imperial value' do
        test_data = TestData.new(nil, 1.0)
        expect( test_data.imperial ).to eq 1.0
      end

      it 'defaults to metric' do
        test_data = TestData.new(200)
        expect( test_data ).to be_metric
        expect( test_data.metric ).to eq 200.0
      end

      context 'when setting the unit type' do
        it 'sets metric via boolean' do
          test_data = TestData.new(true, 200, nil)
          expect( test_data.to_s ).to eq '200 METRIC'
        end

        it 'sets metric via symbol' do
          test_data = TestData.new(:metric, 200, nil)
          expect( test_data.to_s ).to eq '200 METRIC'
        end

        it 'sets imperial via boolean' do
          test_data = TestData.new(false, nil, 1.0)
          expect( test_data.to_s ).to eq '1.0 IMPERIAL'
        end

        it 'sets imperial via symbol' do
          test_data = TestData.new(:imperial, nil, 1.0)
          expect( test_data.to_s ).to eq '1.0 IMPERIAL'
        end

        context 'and only provided one magnitude' do
          context 'and metric is set' do
            it 'interprets magnitude as metric value' do
              test_data = TestData.new(:metric, 200)
              expect( test_data.to_s ).to eq '200 METRIC'
            end
          end

          context 'and imperial is set' do
            it 'interprets magnitude as imperial value' do
              test_data = TestData.new(:imperial, 1)
              expect( test_data.to_s ).to eq '1 IMPERIAL'
            end
          end
        end
      end
    end

    describe '#imperial' do
      it 'calculates imperial value from metric value' do
        test_data = TestData.new(:metric, 200.0)
        expect( test_data.imperial ).to eq 1.0
      end

      it 'returns nil if imperial value is nil' do
        test_data = TestData.new(:imperial, nil)
        expect( test_data.imperial ).to be_nil
      end

      it 'returns known value as imperial value' do
        test_data = TestData.new(:imperial, 1)
        expect( test_data.imperial ).to eq 1
      end

      # it 'keeps integer resolution' do
      #   test_data = TestData.new(:imperial, 10)
      #   expect( test_data.metric ).to eq 16
      # end

      # it 'keeps float resolution' do
      #   test_data = TestData.new(:imperial, 10.0)
      #   expect( test_data.metric ).to eq 16.1
      # end
    end

    describe '#metric' do
      it 'calculates metric value from imperial value' do
        test_data = TestData.new(:imperial, 1.0)
        expect( test_data.metric ).to eq 200.0
      end

      it 'returns nil if metric value is nil' do
        test_data = TestData.new(:metric, nil)
        expect( test_data.metric ).to be_nil
      end

      it 'returns known value as metric value' do
        test_data = TestData.new(:metric, 200)
        expect( test_data.metric ).to eq 200
      end

      # it 'keeps integer resolution' do
      #   test_data = TestData.new(:imperial, 10)
      #   expect( test_data.metric ).to eq 16
      # end

      # it 'keeps float resolution' do
      #   test_data = TestData.new(:imperial, 10.0)
      #   expect( test_data.metric ).to eq 16.1
      # end
    end

    describe '#<=>' do
      context 'when comparing two metric test_datas' do
        it 'returns > correctly' do
          test_data1 = TestData.new(:metric, 200)
          test_data2 = TestData.new(:metric, 200.2)

          expect( test_data2 ).to be > test_data1
        end

        it 'returns == correctly' do
          test_data1 = TestData.new(:metric, 200)
          test_data2 = TestData.new(:metric, 200.0)

          expect( test_data2 ).to eq test_data1
        end

        it 'returns < correctly' do
          test_data1 = TestData.new(:metric, 200)
          test_data2 = TestData.new(:metric, 200.2)

          expect( test_data1 ).to be < test_data2
        end
      end

      context 'when comparing two imperial test_datas' do
        it 'returns > correctly' do
          test_data1 = TestData.new(:imperial, 1)
          test_data2 = TestData.new(:imperial, 1.2)

          expect( test_data2 ).to be > test_data1
        end

        it 'returns == correctly' do
          test_data1 = TestData.new(:imperial, 1)
          test_data2 = TestData.new(:imperial, 1.0)

          expect( test_data2 ).to eq test_data1
        end

        it 'returns < correctly' do
          test_data1 = TestData.new(:imperial, 1)
          test_data2 = TestData.new(:imperial, 1.2)

          expect( test_data1 ).to be < test_data2
        end
      end

      context 'when comparing a mtric and an imperial test_data' do
        it 'returns > correctly' do
          test_data1 = TestData.new(:metric, 200.0)
          test_data2 = TestData.new(:imperial, 1.2)

          expect( test_data2 ).to be > test_data1
        end

        it 'returns == correctly' do
          test_data1 = TestData.new(:metric, 200.0)
          test_data2 = TestData.new(:imperial, 1.0)

          expect( test_data2 ).to eq test_data1
        end

        it 'returns < correctly' do
          test_data1 = TestData.new(:metric, 200.3)
          test_data2 = TestData.new(:imperial, 1.0)

          expect( test_data2 ).to be < test_data1
        end
      end
    end

    describe '#units' do
      context 'when test_data is metric' do
        it 'returns metric value' do
          test_data = TestData.new(:metric, 200.0)
          expect( test_data.units ).to eq 'METRIC'
        end
      end

      context 'when test_data is imperial' do
        it 'returns imperial value' do
          test_data = TestData.new(:imperial, 1.0)
          expect( test_data.units ).to eq 'IMPERIAL'
        end
      end
    end

    describe '#to_i' do
      context 'when test_data is metric' do
        it 'returns the value of metric value' do
          test_data = TestData.new(:metric, 200.0, 1.0)
          expect( test_data.to_i ).to eq 200
        end

        it 'returns 0 if nothing is set' do
          test_data = TestData.new(:metric, nil)
          expect( test_data.to_i ).to eq 0
        end
      end

      context 'when test_data is imperial' do
        it 'returns the value of imperial value' do
          test_data = TestData.new(:imperial, 200.0, 1.0)
          expect( test_data.to_i ).to eq 1
        end

        it 'returns 0 if nothing is set' do
          test_data = TestData.new(:imperial, nil)
          expect( test_data.to_i ).to eq 0
        end
      end
    end

    describe '#to_f' do
      context 'when test_data is metric' do
        it 'returns the value of metric value' do
          test_data = TestData.new(:metric, 200, 1)
          expect( test_data.to_f ).to eq 200.0
        end

        it 'returns 0 if nothing is set' do
          test_data = TestData.new(:metric, nil)
          expect( test_data.to_f ).to eq 0.0
        end
      end

      context 'when test_data is imperial' do
        it 'returns the value of imperial value' do
          test_data = TestData.new(:imperial, 200, 1)
          expect( test_data.to_f ).to eq 1.0
        end

        it 'returns 0 if nothing is set' do
          test_data = TestData.new(:imperial, nil)
          expect( test_data.to_f ).to eq 0.0
        end
      end
    end

    describe '#to_s' do
      context 'when test_data is metric' do
        it 'returns metric value' do
          test_data = TestData.new(:metric, 200)
          expect( test_data.to_s ).to eq '200 METRIC'
        end
      end

      context 'when test_data is imperial' do
        it 'returns imperial value' do
          test_data = TestData.new(:imperial, 1)
          expect( test_data.to_s ).to eq '1 IMPERIAL'
        end
      end
    end

    describe '#nil?' do
      it 'returns true if nothing is set' do
        test_data = TestData.new(nil, nil)
        expect( test_data ).to be_nil
      end

      it 'returns false if only metric value set' do
        test_data = TestData.new(200, nil)
        expect( test_data ).to_not be_nil
      end

      it 'returns false if only imperial value set' do
        test_data = TestData.new(nil, 1)
        expect( test_data ).to_not be_nil
      end
    end
  end
end
