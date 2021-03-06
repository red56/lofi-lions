source 'https://rubygems.org'
ruby "2.4.9"

gem 'rails', '~> 4.2.0'

gem 'nokogiri',  '>= 1.8.2'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'haml'
gem 'haml-rails'
gem 'kramdown', ">= 2.3.0"
gem "kramdown-parser-gfm"

gem 'devise'
gem 'devise-bootstrap-views'

gem 'unicorn'

gem 'simple_form', '~> 3.2'

gem 'bugsnag'

gem "easy_translate"

gem 'rails_12factor'
gem 'lograge'

# needs to be in production because of autoloading... not because it's actually used!
gem "mail_view", "~> 2.0.4"

gem "heroku_tool", github: "red56/heroku_tool", branch: 'master', require: false

group :development do
  gem 'quiet_assets'
  gem 'guard-rails'
  gem 'thin'
  gem 'rack-livereload'
  gem 'guard-livereload'
  gem "spring"
  gem "spring-commands-rspec"
  gem "fix-db-schema-conflicts"
  gem "releasetool", github: "red56/releasetool", branch: 'master'
end

group :test do
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec_junit_formatter' # circleci
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara', '>=2.2.0'
  gem 'capybara-screenshot'
  gem 'bundler-audit', '~> 0.5'
end
