require File.expand_path('../../test_helper', __FILE__)

class SendNotificationsTaskTest < ActiveSupport::TestCase
  test "rake task executes without errors" do
    assert_nothing_raised do
      Rake::Task['due_notifications_webhook:send_notifications'].invoke
    end
  end
end
