require '/usr/src/redmine/test/test_helper'
require 'minitest/mock'

class DueNotificationsWebhook::TeamsNotifierTest < ActiveSupport::TestCase
  def setup
    @webhook_url = "https://example.com/webhook"
    @title = "Test Notification"
    @body = "This is a test notification"
  end

  test "should build correct payload and send HTTP POST" do
    http_mock = Minitest::Mock.new
    request_mock = Minitest::Mock.new
    response_mock = Net::HTTPOK.new("1.1", 200, "OK")

    Net::HTTP.stub :new, http_mock do
      http_mock.expect :use_ssl=, true, [true]
      http_mock.expect :request, response_mock, [Object]
      Net::HTTP::Post.stub :new, request_mock do
        request_mock.expect :body=, nil, [String]
        result = DueNotificationsWebhook::TeamsNotifier.send(
          @webhook_url,
          title: @title,
          body: @body
        )
        assert result.is_a?(Net::HTTPResponse)
        assert_equal 200, result.code
      end
    end
  end
end
