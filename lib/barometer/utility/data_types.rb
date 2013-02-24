module Barometer
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
      def metric_reader *names
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

      def pre_set_reader type, *names
        names.each do |name|
          send :define_method, name do
            value = instance_variable_get("@#{name}")
            unless value
              value = type.new
              instance_variable_set "@#{name}", value
            end
            if value.respond_to?(:metric=)
              value.metric = metric?
            end
            value
          end
        end
      end

      def pre_set_writer type, *names
        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              instance = nil
            elsif data.is_a?(type)
              instance = data
              instance.metric = metric?
            else
              instance = instance_variable_get("@#{name}")
              instance ||= type.new
              instance << data
              instance.metric = metric?
            end
            instance_variable_set "@#{name}", instance
          end
        end
      end

      def temperature *names
        pre_set_reader Data::Temperature, *names
        pre_set_writer Data::Temperature, *names
      end

      def vector *names
        pre_set_reader Data::Vector, *names
        pre_set_writer Data::Vector, *names
      end

      def pressure *names
        pre_set_reader Data::Pressure, *names
        pre_set_writer Data::Pressure, *names
      end

      def distance *names
        pre_set_reader Data::Distance, *names
        pre_set_writer Data::Distance, *names
      end

      def float *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              value = nil
            elsif data.respond_to?(:to_f)
              value = data.to_f
            else
              value = Float(data)
            end
            instance_variable_set "@#{name}", value
          end
        end
      end

      def integer *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              value = nil
            elsif data.respond_to?(:to_i)
              value = data.to_i
            else
              value = Integer(data)
            end
            instance_variable_set "@#{name}", value
          end
        end
      end

      def string *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              value = nil
            else
              value = String(data)
            end
            instance_variable_set "@#{name}", value
          end
        end
      end

      def symbol *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data.respond_to?(:to_sym)
              instance_variable_set "@#{name}", data.to_sym
            elsif data == nil
              instance_variable_set "@#{name}", data
            else
              raise ArgumentError
            end
          end
        end
      end

      def time *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = [data] unless data.is_a?(Array)

            if data.compact.empty?
              time = nil
            elsif data.size == 1 && data.first.is_a?(Time)
              time = data.first
            elsif data.size == 1 && data.first.respond_to?(:to_time)
              time = data.first.to_time
            elsif data.size == 1
              time = Time.parse(*data)
            elsif data.size == 2
              if Time.respond_to?(:strptime)
                # 1.9.x
                time = Time.strptime(*data)
              else
                # 1.8.7
                datetime = DateTime.strptime(*data)
                time = Time.local(
                  datetime.year, datetime.month, datetime.day,
                  datetime.hour, datetime.min, datetime.sec
                )
              end
            else
              time = Time.local(*data)
            end
            instance_variable_set "@#{name}", time
          end
        end
      end

      def local_datetime *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = Array(data)

            if data.compact.empty?
              local_datetime = nil
            elsif data.size <= 2
              local_datetime = Data::LocalDateTime.parse(*data)
            else
              local_datetime = Data::LocalDateTime.new(*data)
            end
            instance_variable_set "@#{name}", local_datetime
          end
        end
      end

      def local_time *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = Array(data)

            if data.compact.empty?
              local_time = nil
            elsif data.size <= 1
              local_time = Data::LocalTime.parse(*data)
            else
              local_time = Data::LocalTime.new(*data)
            end
            instance_variable_set "@#{name}", local_time
          end
        end
      end

      def sun *names
        pre_set_reader Data::Sun, *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              instance_variable_set "@#{name}", nil
            elsif data.is_a?(Data::Sun)
              instance_variable_set "@#{name}", data
            else
              raise ArgumentError
            end
          end
        end
      end

      def location *names
        pre_set_reader Data::Location, *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              instance_variable_set "@#{name}", nil
            elsif data.is_a?(Data::Location)
              instance_variable_set "@#{name}", data
            else
              raise ArgumentError
            end
          end
        end
      end

      def timezone *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            if data == nil
              timezone = nil
            elsif data.is_a?(Data::Zone)
              timezone = data
            elsif data
              timezone = Data::Zone.new(data)
            end
            instance_variable_set "@#{name}", timezone
          end
        end
      end

      def boolean *names
        attr_reader *names

        names.each do |name|
          send :define_method, "#{name}=" do |data|
            data = !!data if data != nil
            instance_variable_set "@#{name}", data
          end

          send :define_method, "#{name}?" do
            !!instance_variable_get("@#{name}")
          end
        end
      end

    end
  end
end
