source 'http://rubygems.org'

platforms :ruby_18 do
  gem 'nokogiri', '~> 1.5.10'
end

group :assets do
  platforms :rbx do
    gem 'pelusa'
  end
end

group :test do
  gem 'coveralls', :require => false
  gem 'activesupport', '~> 3.2.12', :require => false
end

gemspec
