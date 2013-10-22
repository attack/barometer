source 'http://rubygems.org'

gem 'virtus', :github => 'solnic/virtus', :ref => 'a9717573dc0ceb5ff7ca40f8c25e89a366304b80'

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
