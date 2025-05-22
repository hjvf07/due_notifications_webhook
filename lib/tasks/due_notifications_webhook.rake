# lib/tasks/due_notifications_webhook.rake

namespace :due_notifications_webhook do
  desc "Send due date notifications to Microsoft Teams via WebHook"
  task send_notifications: :environment do
    require_dependency 'due_notifications_webhook/teams_notifier'
    require_dependency 'due_notifications_webhook/message_templates'

    settings = Setting.plugin_due_notifications_webhook || {}
    webhook_url = settings['webhook_url']
    days_before = settings['days_before_due'].to_i
    days_after  = settings['days_after_due'].to_i
    send_time = settings['send_time'].to_s.strip
    label_due_notifications_sent = I18n.t('label_due_notifications_sent')
    label_due_notifications_abort = I18n.t('label_due_notifications_abort')
    label_due_notifications_current_time = I18n.t('label_due_notifications_current_time')
    label_due_notifications_task_will = I18n.t('label_due_notifications_task_will')
    label_due_notifications_not_match = I18n.t('label_due_notifications_not_match')
    label_due_notifications_days = I18n.t('label_due_notifications_days')
    label_due_notifications_sent_notification = I18n.t('label_due_notifications_sent_notification')
    label_due_notifications_today = I18n.t('label_due_notifications_today')
    label_due_notifications_day = I18n.t('label_due_notifications_day') 

    # ======= Checking the sending time ==========
    if send_time.present?
      now = Time.now.strftime("%H:%M")
      unless now == send_time
        puts "#{label_due_notifications_current_time} #{now} #{label_due_notifications_not_match} #{send_time}. #{label_due_notifications_task_will}"
        next
      end
    end
    # ===========================================

    if webhook_url.blank?
      puts "#{label_due_notifications_abort}"
      next
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
      puts "#{label_due_notifications_sent_notification} ##{issue.id} (due in #{days_left_text})"
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
      puts "#{label_due_notifications_sent_notification} ##{issue.id} (overdue by #{days_overdue_text})"
    end

    puts "#{label_due_notifications_sent}."
  end
end
