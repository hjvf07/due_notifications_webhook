# Due Notifications Webhook for Redmine

!Redmine 5.x/6.x

## Description

**due_notifications_webhook** is a Redmine plugin that automatically sends notifications to Microsoft Teams (via Incoming Webhook) about issues that are approaching their due date or are overdue.

- **Supported Redmine versions:** 5.x and 6.x
- **Daily notifications** about upcoming or overdue tasks
- **Separate templates** for "due soon" and "overdue" messages
- **Configurable:** set send time, webhook URL, days before/after due date, and manual trigger via settings page

---

## Installation

1. Clone the plugin into your Redmine `plugins/` directory:
    ```sh
    cd /path/to/redmine/plugins
    git clone <REPO_URL> due_notifications_webhook
    ```

2. Restart your Redmine server.

3. Navigate to **Administration → Plugins → Due Notifications Webhook** to configure settings.

---

## Plugin Settings

On the plugin settings page, you can configure:

- **Message send time** — time of day to send notifications (format: `HH:MM`, e.g., `09:00`)
- **Microsoft Teams Webhook URL** — your Teams channel webhook URL
- **Days before due date to notify** — how many days before the due date to send a warning
- **Days after due date to notify** — how many days after the due date to send reminders
- **Send message now** — a button to send all notifications immediately (manual trigger)

---

## Scheduled Notifications (via Cron)

> **To ensure notifications are sent automatically at the desired time, schedule the rake task with cron.**

### **1. Add to crontab:**

#### If running Redmine in Docker (replace `redmine-6` with your container name):

```sh
*/5 * * * * docker exec -i redmine-6 bash -c "cd /usr/src/redmine && PATH=/usr/local/bundle/bin:/usr/local/bin:/usr/bin:/bin && bundle exec rake due_notifications_webhook:send_notifications >> /usr/src/redmine/log/due_notifications_webhook.log 2>&1"
```

#### If running Redmine directly (no Docker):

```sh
*/5 * * * * cd /path/to/redmine && PATH=/usr/local/bundle/bin:/usr/local/bin:/usr/bin:/bin && bundle exec rake due_notifications_webhook:send_notifications >> log/due_notifications_webhook.log 2>&1
```

#### Cron runs the task every 5 minutes.
#### The plugin itself checks the time and sends notifications only at the time specified in the settings (e.g., 09:00).
#### All output is logged to log/due_notifications_webhook.log
```

## How to create Webhooks for MS Teams

1. Active license for Office 365 Business package
2. Create account on https://powerautomate.com/ with corporate email
3. Create new flow
3.1. Choose Create tab on sidebar
3.2. Select "Instant cloud flow"

---

## Structure of the plugin

```sh
redmine_due_notifications_webhook/
├── app/
│   └── controllers/
│        └── due_notifications_webhook_controller.rb
│   └── views/
│        └── settings/
│             └── _settings.html.erb
│
├── config/
│   └── locales/
│        ├── en.yml
│        ├── ja.yml
│        └── uk.yml
│   └── routes.rb
│
├── lib/
│   └── due_notifications_webhook/
│        ├── message_templates.rb
│        └── teams_notifier.rb
│   └── tasks/
│        └── due_notifications_webhook.rake
│
├── spec/
│   └── lib/
│        └── teams_notifier_spec.rb
│   └── rails_helper.rb
│
├── test/
│   └── unit/
│       ├── send_notifications_task_test.rb
│       └── teams_notifier_test.rb
│
├── Gemfile.local
├── .rspec
├── init.rb
└── README.md
```
> **Running the test**

```sh
bin/rspec plugins/due_notifications_webhook/spec/lib/teams_notifier_spec.rb
```
123