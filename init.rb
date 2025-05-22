require 'redmine'

lib_path = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

Redmine::Plugin.register :due_notifications_webhook do
  name 'Due Notifications Webhook'
  author 'Agileware Inc.'
  description 'Sends due date notifications to Microsoft Teams via WebHook. Supports Redmine 5.x and 6.x.'
  version '0.1.0'
  url 'https://github.com/your-org/redmine_due_notifications_webhook'
  author_url 'https://your-website.com'

  settings default: {
    'send_time' => '09:00',
    'webhook_url' => '',
    'days_before_due' => '2',
    'days_after_due' => '2'
  }, partial: 'settings/settings'
end