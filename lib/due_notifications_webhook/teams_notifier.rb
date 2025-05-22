require 'net/http'
require 'uri'
require 'json'

module DueNotificationsWebhook
  class TeamsNotifier
    def self.send(webhook_url, title:, body:)
      payload = {
        "@type" => "MessageCard",
        "@context" => "http://schema.org/extensions",
        "summary" => title,
        "themeColor" => "0078D7",
        "title" => title,
        "text" => body
      }

      uri = URI.parse(webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      request.body = payload.to_json
      response = http.request(request)
      label_due_notifications_teams_error = I18n.t('label_due_notifications_teams_error')
      label_due_notifications_webhook_exception = I18n.t('label_due_notifications_webhook_exception')

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "#{label_due_notifications_teams_error} #{response.code} #{response.body}"
      end
      response
    rescue => e
      label_due_notifications_teams_error = I18n.t('label_due_notifications_teams_error')
      Rails.logger.error "#{label_due_notifications_teams_error} #{e.message}"
      nil
    end
  end
end
