require 'rspec/expectations'
require File.expand_path(File.dirname(__FILE__) + '/formats')
require File.expand_path(File.dirname(__FILE__) + '/path')

module BarometerMatchers
  extend RSpec::Matchers::DSL
  include BarometerMatcherFormats

  matcher :forecast do |*paths|
    match do |response|
      @result = Walker.new(response.forecast[0]).follow(paths)

      if @format
        is_of_format?(@format, @result)
      else
        @result == @value || @result.to_f == @value
      end
    end

    description do
      "have correct forecast value for #{paths.join('.')}"
    end

    failure_message_for_should do |response|
      "expected that '#{@result}' matches '#{@value || @format}'"
    end

    chain :as_value do |value|
      @value = value
    end

    chain :as_format do |format|
      @format = format
    end
  end
end
