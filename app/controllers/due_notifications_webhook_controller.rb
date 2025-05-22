class DueNotificationsWebhookController < ApplicationController
  before_action :require_admin

  # POST /due_notifications_webhook/send_now
  def send_now
    require_dependency 'due_notifications_webhook/teams_notifier'
    require_dependency 'due_notifications_webhook/message_templates'

    settings = Setting.plugin_due_notifications_webhook || {}
    webhook_url = settings['webhook_url']
    days_before = settings['days_before_due'].to_i
    days_after  = settings['days_after_due'].to_i
    label_due_notifications_webhook_settings = I18n.t('label_due_notifications_webhook_settings')
    label_due_notifications_sent = I18n.t('label_due_notifications_sent')
    label_due_notifications_error = I18n.t('label_due_notifications_error')
    label_due_notifications_today = I18n.t('label_due_notifications_today')
    label_due_notifications_day = I18n.t('label_due_notifications_day')
    label_due_notifications_days = I18n.t('label_due_notifications_days')

    if webhook_url.blank?
      render json: { message: label_due_notifications_webhook_settings }, status: 400
      return
    end

    today = Date.today

    if days_before > 0
      due_soon_issues = Issue.where(due_date: (today)..(today + days_before))
                            .where(status_id: IssueStatus.where(is_closed: false))
                            .includes(:project, :assigned_to)
    else
      due_soon_issues = []
    end

    if days_after > 0
      overdue_issues = Issue.where(due_date: (today - days_after)..(today - 1))
                            .where(status_id: IssueStatus.where(is_closed: false))
                            .includes(:project, :assigned_to)
    else
      overdue_issues = []
    end

    count_sent = 0

    due_soon_issues.each do |issue|
      issue_url = Rails.application.routes.url_helpers.issue_url(issue, host: Setting.host_name)
      days_left = (issue.due_date - today).to_i
      days_left_text =
        if days_left == 0
          "#{label_due_notifications_today}"
        elsif days_left == 1
          "#{days_left} #{label_due_notifications_day}"
        else
          "#{days_left} #{label_due_notifications_days}"
        end
      title, body = DueNotificationsWebhook::MessageTemplates.due_soon(issue, days_left_text, issue_url)
      DueNotificationsWebhook::TeamsNotifier.send(
        webhook_url,
        title: title,
        body: body
      )
      count_sent += 1
    end

    overdue_issues.each do |issue|
      issue_url = Rails.application.routes.url_helpers.issue_url(issue, host: Setting.host_name)
      days_overdue = (today - issue.due_date).to_i
      days_overdue_text =
        if days_overdue == 0
          "#{label_due_notifications_today}"
        elsif days_overdue == 1
          "#{days_overdue} #{label_due_notifications_day}"
        else
          "#{days_overdue} #{label_due_notifications_days}"
        end
      title, body = DueNotificationsWebhook::MessageTemplates.overdue(issue, days_overdue_text, issue_url)
      DueNotificationsWebhook::TeamsNotifier.send(
        webhook_url,
        title: title,
        body: body
      )
      count_sent += 1
    end

    render json: { message: "#{label_due_notifications_sent}: #{count_sent}" }
  rescue => e
    render json: { message: "#{label_due_notifications_error} #{e.message}" }, status: 500
  end
end
