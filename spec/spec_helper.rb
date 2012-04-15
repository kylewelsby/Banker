unless ENV['TRAVIS']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec'
  end
end

require 'rspec'
require 'webmock/rspec'
require 'banker'

RSpec.configure do |config|
  config.order = :rand
  config.color_enabled = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
