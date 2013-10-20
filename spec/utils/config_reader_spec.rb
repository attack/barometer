require_relative '../spec_helper'

describe Barometer::Base do
  around do |example|
    cached_config = Barometer.config
    example.run
    Barometer.config = cached_config
  end

  describe ".take_level_while" do
    context "when multiple tiers are configured" do
      before { Barometer.config = { 1 => :foo, 2 => :bar } }

      context "and the first iteration returns false" do
        it "only yields once" do
          expect { |b|
            m = Proc.new do |*args|
              b.to_proc.call(*args)
              false
            end

            Barometer::Utils::ConfigReader.take_level_while(&m)
          }.to yield_successive_args(1)
        end
      end

      context "and the first iterations returns true" do
        it "yields multiple times" do
          expect { |b|
            m = Proc.new do |*args|
              b.to_proc.call(*args)
              true
            end

            Barometer::Utils::ConfigReader.take_level_while(&b)
          }.to yield_successive_args(1, 2)
        end
      end
    end

    context "when only one tier is configured" do
      before { Barometer.config = { 1 => :foo } }

      context "and the first iteration returns false" do
        it "only yields once" do
          expect { |b|
            Barometer::Utils::ConfigReader.take_level_while(&b)
          }.to yield_successive_args(1)
        end
      end

      context "and the first iterations returns true" do
        it "only yields once" do
          expect { |b|
            Barometer::Utils::ConfigReader.take_level_while(&b)
          }.to yield_successive_args(1)
        end
      end
    end

    context "when no tiers are configured" do
      it "never yields" do
        Barometer.config = {}

        expect { |b|
          Barometer::Utils::ConfigReader.take_level_while(&b)
        }.not_to yield_control
      end
    end
  end

  describe ".services" do
    context "when there is one service for the tier" do
      context "and that service is just a symbol" do
        it "calls the block with no config" do
          Barometer.config = { 1 => :test }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_with_args(:test, {})
        end
      end

      context "and that service is just a string" do
        it "calls the block with no config" do
          Barometer.config = { 1 => 'test' }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_with_args(:test, {})
        end
      end

      context "and that service is in an array" do
        it "calls the block with no config" do
          Barometer.config = { 1 => [:test] }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_with_args(:test, {})
        end
      end

      context "and that service is a hash with options" do
        it "calls the block with the options" do
          Barometer.config = { 1 => {test: {version: :v1} } }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_with_args(:test, {version: :v1})
        end
      end

      context "and that service is a hash with options in an array" do
        it "calls the block with the options" do
          Barometer.config = { 1 => [{test: {version: :v1} }] }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_with_args(:test, {version: :v1})
        end
      end
    end

    context "when there are multiple services for the tier" do
      context "and both services have no opitons" do
        it "calls the block twice without options" do
          Barometer.config = { 1 => [:foo, :bar] }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_successive_args([:foo, {}], [:bar, {}])
        end
      end

      context "and one service has no options, one has options" do
        it "calls the block twice with and without options" do
          Barometer.config = { 1 => [:foo, {bar: {version: :v1}}] }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_successive_args([:foo, {}], [:bar, {version: :v1}])
        end
      end

      context "and both services have opitons" do
        it "calls the block twice with options" do
          Barometer.config = { 1 => [{foo: {weight: 2}}, {bar: {version: :v1}}] }

          expect { |b|
            Barometer::Utils::ConfigReader.services(1, &b)
          }.to yield_successive_args([:foo, {weight: 2}], [:bar, {version: :v1}])
        end
      end
    end
  end
end
