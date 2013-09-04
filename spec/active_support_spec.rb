require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Compatibility with ActiveSupport ~> 3.2.12', :vcr => {
  :cassette_name => "active_support",
  :record => :all
}, :with_active_support => true do

  require 'active_support/core_ext/string/conversions'

  it 'parses wundergound date' do
    Barometer.config = {1=>{:wunderground=>{:version=>:v1}}}
    w = Barometer.new("London, England").measure.current
    w.observed_at.year.should_not == 0
    w.stale_at.year.should_not == 0
  end

  it 'parses yahoo date' do
    Barometer.config = {1=>{:yahoo=>{:version=>:v1}}}
    w = Barometer.new("London, England").measure.current
    w.observed_at.year.should_not == 0
    w.stale_at.year.should_not == 0
  end
end
