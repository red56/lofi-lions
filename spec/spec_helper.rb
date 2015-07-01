# require 'webmock/rspec'
# WebMock.disable_net_connect! allow_localhost: true

RSpec.configure do |config|
  config.backtrace_exclusion_patterns << /gems/
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec
end

