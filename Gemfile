source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'sqlite3'
gem 'rails', '~> 5.1.3'
gem 'puma', '~> 3.7'
gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 3.0'
gem 'resque', '~> 1.27'
gem 'resque-web', require: 'resque_web'
gem 'rails_admin', '~> 1.2'
gem 'activerecord-import', '~> 0.19'

group :development, :test do
  # gem 'sqlite3'
  gem 'byebug'
  gem 'rspec-rails'
  gem 'rspec-its'
end

group :production do
  # gem 'mysql2'
  # ExecJS runtime
  gem 'therubyracer', require: 'v8'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end
