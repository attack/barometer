# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{barometer}
  s.version = "0.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = %q{1.3.5}

  s.authors = ["Mark G"]
  s.email = %q{barometer@attackcorp.com}
  s.date = %q{2011-06-02}

  s.summary = %q{A multi API consuming weather forecasting superstar.}
  s.description = %q{A multi API consuming weather forecasting superstar.}
  s.homepage = %q{http://github.com/attack/barometer}

  s.default_executable = %q{barometer}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency(%q<httparty>, ">= 0.4.5")
  s.add_dependency(%q<tzinfo>, ">= 0.3.14")
  s.add_dependency("nokogiri")

  s.add_development_dependency("rspec", "~> 2.6")
  s.add_development_dependency("mocha")
  s.add_development_dependency("fakeweb")
end

