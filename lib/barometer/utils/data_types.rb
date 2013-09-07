module Barometer
  module Utils
    module DataTypes
      def self.included base
        base.send :include, InstanceMethods
        base.extend ClassMethods
      end

      module InstanceMethods
        def metric=(value); @metric = !!value; end
        def metric; @metric; end
        def metric?;  @metric || @metric.nil?;  end
      end

      module ClassMethods
        def pre_set_reader type, *names
          names.each do |name|
            send :define_method, name do
              value = instance_variable_get("@#{name}")
              unless value
                value = type.new
                instance_variable_set "@#{name}", value
              end
              value
            end
          end
        end

        def new_pre_set_reader type, *names
          names.each do |name|
            send :define_method, name do
              value = instance_variable_get("@#{name}")
              if value.respond_to?(:metric=)
                value.metric = metric?
              end
              value
            end
          end
        end

        def new_pre_set_writer type, *names
          names.each do |name|
            send :define_method, "#{name}=" do |data|
              return unless instance_variable_get("@#{name}").nil?
              if data.is_a?(type)
                instance = data
              else
                instance = type.new(*data)
              end
              instance.metric = metric?
              instance_variable_set "@#{name}", instance
            end
          end
        end

        def typecast_writer klass, converter, *names
          names.each do |name|
            send :define_method, "#{name}=" do |data|
              # return unless instance_variable_get("@#{name}").nil?
              return if data.nil?

              # if klass && data.is_a?(klass)
                # value = data
              if converter && data.respond_to?(converter)
                value = data.send(converter)
              elsif klass && Kernel.respond_to?(klass.to_s)
                value = Kernel.send(klass.to_s, data)
              else
                raise ArgumentError
              end
              instance_variable_set "@#{name}", value
            end
          end
        end

        def vector *names
          new_pre_set_reader Barometer::Data::Vector, *names
          new_pre_set_writer Barometer::Data::Vector, *names
        end

        def pressure *names
          new_pre_set_reader Data::Pressure, *names
          new_pre_set_writer Data::Pressure, *names
        end

        def distance *names
          new_pre_set_reader Data::Distance, *names
          new_pre_set_writer Data::Distance, *names
        end

        def time *names
          attr_reader *names

          names.each do |name|
            send :define_method, "#{name}=" do |data|
              data = [data] unless data.is_a?(Array)
              return unless data && data.first

              time = Barometer::Utils::Time.parse(*data)
              instance_variable_set "@#{name}", time
            end
          end
        end

        def sun *names
          pre_set_reader Data::Sun, *names

          names.each do |name|
            send :define_method, "#{name}=" do |data|
              return if data.nil?
              if data.is_a?(Data::Sun)
                instance_variable_set "@#{name}", data
              else
                raise ArgumentError
              end
            end
          end
        end
      end
    end
  end
end
