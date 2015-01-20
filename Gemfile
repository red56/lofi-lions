source 'https://rubygems.org'
ruby "2.0.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'

gem 'nokogiri'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'bootstrap-sass-rails'
gem 'font-awesome-sass'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'haml'
gem 'haml-rails'

gem 'devise'

gem 'unicorn'
gem 'rack-timeout'

gem 'simple_form', github: 'plataformatec/simple_form'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# needs to be in production because of autoloading... not because it's actually used!
gem "mail_view", "~> 2.0.4"

group :development do
  gem 'quiet_assets'
  gem 'guard'
  gem 'guard-livereload'
  gem 'rack-livereload'
  gem "spring"
  gem "spring-commands-rspec"
end

group :test do
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'faker'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara', '>=2.2.0'
  gem "releasetool", github: "red56/releasetool", branch: 'master'
end
