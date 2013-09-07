module Barometer
  module Data
    module Attribute
      class Temperature < Virtus::Attribute::Object
        primitive Data::Temperature
        default nil

        class Temperature < Virtus::Attribute::Writer::Coercible
          def coerce(value)
            value = super

            if value.nil?
              primitive.new
            elsif value.is_a? primitive
              value
            else
              primitive.new(*value)
            end
          end

          def call(instance, value)
            value = super(instance, coerce(value))
            value.metric = instance.metric?
            value
          end
        end

        class MetricReader < Virtus::Attribute::Reader
          def call(instance)
            value = super
            value.metric = instance.metric?
            value
          end
        end

        def self.writer_class(*args)
          Temperature
        end

        def self.reader_class(*args)
          MetricReader
        end
      end
    end
  end
end
