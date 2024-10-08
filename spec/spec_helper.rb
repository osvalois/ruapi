# spec/spec_helper.rb
require 'dotenv/load'
require 'rspec'
require 'webmock/rspec'
require 'vcr'

require_relative '../lib/easybroker_client'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<API_KEY>') { ENV['EASYBROKER_API_KEY'] }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# .rubocop.yml
AllCops:
  NewCops: enable
  TargetRubyVersion: 2.7

Style/Documentation:
  Enabled: false

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
