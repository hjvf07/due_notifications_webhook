require File.expand_path('../../../../../spec/rails_helper', __FILE__)
require 'webmock/rspec'

RSpec.describe DueNotificationsWebhook::TeamsNotifier, type: :model do
  let(:webhook_url) { "https://example.com/webhook" }
  let(:title) { "Test Notification" }
  let(:body) { "This is a test notification" }

  it "sends a POST request to the webhook URL" do
    stub = stub_request(:post, webhook_url)
             .with(
               headers: {'Content-Type'=>'application/json'},
               body: /"title":"Test Notification"/
             )
             .to_return(status: 200, body: "ok")

    response = described_class.send(
      webhook_url,
      title: title,
      body: body
    )

    expect(response.code).to eq("200")
    expect(stub).to have_been_requested
  end

  it "logs an error on HTTP failure" do
    stub_request(:post, webhook_url).to_return(status: 400, body: "Bad Request")

    expect(Rails.logger).to receive(:error).with(/Teams Webhook error/)
    described_class.send(
      webhook_url,
      title: title,
      body: body
    )
  end

  it "logs an exception if something goes wrong" do
    expect(Net::HTTP).to receive(:new).and_raise(StandardError.new("fail!"))
    expect(Rails.logger).to receive(:error).with(/Teams Webhook error: fail!/)
    described_class.send(
      webhook_url,
      title: title,
      body: body
    )
  end
end
