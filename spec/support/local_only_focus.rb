# keeping this local only so that CI server makes sure to run everything!
RSpec.configure do |c|
  puts c
  c.filter_run :focus => true unless ENV['RSPEC_RUN_ALL']
  c.run_all_when_everything_filtered = true
end
