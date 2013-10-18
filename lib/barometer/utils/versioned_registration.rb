module Barometer
  module Utils
    class VersionedRegistration
      def initialize
        @registrations = {}
      end

      def register(key, *args, &block)
        if block_given?
          version = args.shift
          value = block
        elsif args.size > 1
          version = args.shift
          value = args.shift
        else
          version = nil
          value = args.shift
        end

        return if has_version?(key, version)
        add_value(key, version, value)
      end

      def find(key, version=nil)
        return unless has_key?(key)
        registration = find_version(key, version) || find_default(key) || {}
        registration.fetch(:value, nil)
      end

      def size
        @registrations.inject(0){|count,key_value| key_value[1].size + count }
      end

      private

      def has_key?(key)
        @registrations.has_key? key
      end

      def has_version?(key, version)
        registrations_for_key = @registrations[key] || []
        registrations_for_key.detect{|r| r[:version] == (version || :default)}
      end

      def add_value(key, version, value)
        registration = {
          version: (version || :default),
          value: value
        }
        add_registration(key, registration)
      end

      def add_registration(key, registration)
        registrations_for_key = @registrations[key] || []
        registrations_for_key << registration
        @registrations[key] = registrations_for_key
      end

      def find_version(key, version)
        registrations = @registrations[key]
        registrations.detect{|r| r[:version] == version}
      end

      def find_default(key)
        registrations = @registrations[key]
        registrations.detect{|r| r[:version] == :default}
      end
    end
  end
end
