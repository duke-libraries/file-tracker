source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.6', '>= 5.1.6.2'
gem 'jbuilder', '~> 2.5'
gem 'devise', '>= 4.6.0'
gem 'omniauth-shibboleth'
gem 'cancancan'
gem 'nokogiri', '>= 1.8.1'
gem 'redis', '~> 4.0'
gem 'resque', '~> 2.0'
gem 'resque-web', require: 'resque_web'
gem 'resque-pool', '~> 0.7.0'
gem 'rails_admin', '~> 1.3'
gem 'mysql2'
gem 'mini_racer'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'webmock'
end
