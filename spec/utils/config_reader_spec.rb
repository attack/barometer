require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Barometer::Base do
  before do
    @cached_config = Barometer.config
  end

  after do
    Barometer.config = @cached_config
  end

  describe ".each_service" do
    context "when there is one service for the tier" do
      context "and that service is just a symbol" do
        it "calls the block with no config" do
          Barometer.config = { 1 => :test }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_with_args(:test, nil)
        end
      end

      context "and that service is just a string" do
        it "calls the block with no config" do
          Barometer.config = { 1 => 'test' }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_with_args(:test, nil)
        end
      end

      context "and that service is in an array" do
        it "calls the block with no config" do
          Barometer.config = { 1 => [:test] }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_with_args(:test, nil)
        end
      end

      context "and that service is a hash with options" do
        it "calls the block with the options" do
          Barometer.config = { 1 => {:test => {:version => :v1} } }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_with_args(:test, {:version => :v1})
        end
      end

      context "and that service is a hash with options in an array" do
        it "calls the block with the options" do
          Barometer.config = { 1 => [{:test => {:version => :v1} }] }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_with_args(:test, {:version => :v1})
        end
      end
    end

    context "when there are multiple services for the tier" do
      context "and both services have no opitons" do
        it "calls the block twice without options" do
          Barometer.config = { 1 => [:foo, :bar] }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_successive_args([:foo, nil], [:bar, nil])
        end
      end

      context "and one service has no options, one has options" do
        it "calls the block twice with and without options" do
          Barometer.config = { 1 => [:foo, {:bar => {:version => :v1}}] }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_successive_args([:foo, nil], [:bar, {:version => :v1}])
        end
      end

      context "and both services have opitons" do
        it "calls the block twice with options" do
          Barometer.config = { 1 => [{:foo => {:weight => 2}}, {:bar => {:version => :v1}}] }

          expect { |b|
            Barometer::Utils::ConfigReader.each_service(1, &b)
          }.to yield_successive_args([:foo, {:weight => 2}], [:bar, {:version => :v1}])
        end
      end
    end

    context "when there are no services for the tier" do
      it "raises OutOfSources" do
        expect {
          Barometer::Utils::ConfigReader.each_service(2) {}
        }.to raise_error( Barometer::OutOfSources )
      end
    end
  end
end
