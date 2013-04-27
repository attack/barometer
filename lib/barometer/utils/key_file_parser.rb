module Barometer
  KEY_FILE = File.expand_path(File.join('~', '.barometer'))

  module Utils
    class KeyFileParser
      def self.find(*paths)
        if File.exists?(KEY_FILE)
          keys = YAML.load_file(KEY_FILE)

          paths.each do |path|
            if keys && keys.has_key?(path.to_s)
              keys = keys.fetch(path.to_s)
            else
              keys = nil
            end
          end
          keys
        end
      end
    end
  end
end
