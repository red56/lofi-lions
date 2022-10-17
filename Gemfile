source 'https://rubygems.org'
ruby "2.5.9"

gem 'rails', '~> 5.0.7'

gem 'nokogiri',  '>= 1.8.2'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem "execjs", "= 2.7.0" # can't use ExecJS 2.8+ until Ruby 2.7 see https://github.com/rails/execjs/issues/99 # TODO: remove on ruby 2.7

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'haml'
gem 'haml-rails'
gem 'kramdown', ">= 2.3.0"
gem "kramdown-parser-gfm"

gem 'devise'
gem 'devise-bootstrap-views'

gem 'puma'
gem "barnes"

gem 'simple_form'

gem 'bugsnag'

gem "easy_translate"

gem 'rails_12factor'
gem 'lograge'


group :development do
  gem 'guard-rails'
  gem 'rack-livereload'
  gem 'guard-livereload'
  gem "spring"
  gem "spring-commands-rspec"
  gem "fix-db-schema-conflicts"
  gem "releasetool", github: "red56/releasetool", branch: 'master'
  gem "heroku_tool", github: "red56/heroku_tool", branch: 'main', require: false

  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
end

group :test do
  gem 'launchy'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec_junit_formatter' # circleci
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara', '>=2.2.0'
  gem 'capybara-screenshot'
  gem 'bundler-audit'
end
