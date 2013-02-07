# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barometer/version'

Gem::Specification.new do |s|
  s.name = %q{barometer}
  s.version = Barometer::VERSION
  s.authors = ["Mark G"]
  s.email = %q{barometer@attackcorp.com}
  s.summary = %q{A multi API consuming weather forecasting superstar.}
  s.description = %q{A multi API consuming weather forecasting superstar.}
  s.homepage = %q{http://github.com/attack/barometer}

  s.default_executable = %q{barometer}

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency %q<httparty>, ">= 0.4.5"
  s.add_dependency %q<tzinfo>, ">= 0.3.14"
  s.add_dependency "nokogiri"
  s.add_dependency "crack"

  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "fakefs"
end
