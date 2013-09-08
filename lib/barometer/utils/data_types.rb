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
