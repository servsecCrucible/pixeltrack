source 'https://rubygems.org'
ruby '2.3.1'

gem 'sinatra'
gem 'thin'
gem 'json'
gem 'sequel'
gem 'rbnacl-libsodium'
gem 'rack-ssl-enforcer'

group :development, :test do
  gem 'sqlite3'
  gem 'config_env'
end

group :development do
  gem 'rerun'
  gem 'tux'
  gem 'hirb'
end

group :test do
  gem 'minitest'
  gem 'rack'
  gem 'rack-test'
  gem 'rake'
end

group :production do
  gem 'pg'
end
