require 'rspec/expectations'

module BarometerMatcherFormats
  def is_of_format?(format, value)
    value.match(_find_regex(format))
  end

  def _find_regex(format)
    case format
    when :datetime
      /^\d{1,2}:\d{1,2}[ ]?[apmAPM]{0,2}$/i
    when :date
      /^\d{1,4}-\d{1,2}-\d{1,2}$/i
    when :optional_string
      /^[\w ]+$/i
    when :string
      /^[\w ]{2,}$/i
    when :number
      /^\d{1,3}$/i
    when :temperature
      /^\d{1,3}[ ]?[cfCF]?$/i
    when :wind
      /^\d{1,3}[ ]?[a-zA-Z]{0,3}$/i
    when :wind_direction
      /^([neswNESW]{0,3}|east|west|north|south)$/i
    when :pressure
      /^\d{1,4}[ ]?[a-zA-Z]{0,3}$/i
    when Regexp
      format
    end
  end
end
