unless ENV['TRAVIS']
  require 'simplecov'
  SimpleCov.start
end

require 'rspec'
require 'webmock/rspec'
require 'banker'

RSpec.configure do |config|
  # nothing
end
