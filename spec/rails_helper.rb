# plugins/due_notifications_webhook/spec/rails_helper.rb

# Load the Redmine environment
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'

# Require support files
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = File.expand_path('fixtures', __dir__)
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

WebMock.disable_net_connect!(allow_localhost: true)
