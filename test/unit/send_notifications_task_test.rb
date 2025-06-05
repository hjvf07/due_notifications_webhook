# /test/unit/send_notifications_task_test.rb

require '/usr/src/redmine/test/test_helper'
require 'rake'

class SendNotificationsTaskTest < ActiveSupport::TestCase
  def setup
    Rails.application.load_tasks unless Rake::Task.task_defined?('due_notifications_webhook:send_notifications')
  end

  test "rake task executes without errors" do
    assert_nothing_raised do
      Rake::Task['due_notifications_webhook:send_notifications'].reenable # Allow running the task multiple times in test
      Rake::Task['due_notifications_webhook:send_notifications'].invoke
    end
  end
end
