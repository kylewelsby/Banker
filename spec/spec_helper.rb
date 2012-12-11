unless ENV['TRAVIS']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec'
  end
end

require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'banker'

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
  config.order = :rand
  config.color_enabled = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

VCR.configure do |c|
  c.cassette_library_dir = 'cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :none }
end
