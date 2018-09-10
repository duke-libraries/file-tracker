source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.6'
gem 'jbuilder', '~> 2.5'
gem 'figaro'
gem 'devise'
gem 'omniauth-shibboleth'
gem 'cancancan'
gem 'nokogiri', '>= 1.8.1'

gem 'redis', '~> 3.0'
gem 'resque', '~> 1.27'
gem 'resque-web', require: 'resque_web'
gem 'resque-pool'

gem 'rails_admin', '~> 1.3.0'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'webmock'
end

group :production do
  gem 'mysql2'
  gem 'therubyracer', require: 'v8'
end

group :development do
  # For compatibility with Ruby 2.2.2.
  # See https://github.com/e2/ruby_dep.
  gem 'listen', '~> 3.0.8'
end
