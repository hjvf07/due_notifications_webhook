require File.expand_path('../../test_helper', __FILE__)

class DueNotificationsWebhook::TeamsNotifierTest < ActiveSupport::TestCase
  def setup
    @webhook_url = "https://example.com/webhook"
    @issue_url = "https://redmine.test/issues/1"
    @title = "Test Notification"
    @body = "This is a test notification"
  end

  test "should build correct payload and send HTTP POST" do
    # Підміна Net::HTTP для перехоплення POST
    uri = URI.parse(@webhook_url)
    http_mock = Minitest::Mock.new
    request_mock = Minitest::Mock.new
    response_mock = Net::HTTPOK.new("1.1", 200, "OK")

    Net::HTTP.stub :new, http_mock do
      http_mock.expect :use_ssl=, true, [true]
      http_mock.expect :request, response_mock, [Net::HTTP::Post]
      Net::HTTP::Post.stub :new, request_mock do
        request_mock.expect :body=, nil, [String]
        result = DueNotificationsWebhook::TeamsNotifier.send(
          @webhook_url,
          title: @title,
          body: @body,
          issue_url: @issue_url
        )
        assert result.is_a?(Net::HTTPResponse)
        assert_equal "200", result.code
      end
    end
  end
end
