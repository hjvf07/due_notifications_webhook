module DueNotificationsWebhook
  module MessageTemplates
    def self.due_soon(issue, days_left, issue_url)
      title = "⏱️ #{I18n.t('label_due_notifications_issue_etention')}!!!"
      body = <<~HTML
        <b>⏱️ #{I18n.t('label_due_notifications_issue_etention')}!!!</b>
        <hr/>
        <b>🔖 #{I18n.t('field_subject')}:</b> <a href="#{issue_url}">🔗 ##{issue.id} - #{issue.subject}</a><br/>
        <b>📁 #{I18n.t('field_project')}:</b> #{issue.project.name}<br/>
        <b>🧑 #{I18n.t('field_assigned_to')}:</b> #{issue.assigned_to&.name || "-"}<br/>
        <b>📅 #{I18n.t('field_due_date')}:</b> #{issue.due_date}<br/>
        <hr/>
        <i>#{I18n.t('label_due_notifications_pay_attention')} 
        <b>** #{days_left} **!</b></i>
      HTML
      [title, body]
    end

    def self.overdue(issue, days_overdue, issue_url)
      title = "⚠️ #{I18n.t('label_due_notifications_overdue_on')}!!!"
      body = <<~HTML
        <b>⚠️ #{I18n.t('label_due_notifications_overdue_on')}!!!</b>
        <hr/>
        <b>🔖 #{I18n.t('field_subject')}:</b> <a href="#{issue_url}">🔗 ##{issue.id} - #{issue.subject}</a><br/>
        <b>📁 #{I18n.t('field_project')}:</b> #{issue.project.name}<br/>
        <b>🧑 #{I18n.t('field_assigned_to')}:</b> #{issue.assigned_to&.name || "-"}<br/>
        <b>📅 #{I18n.t('field_due_date')}:</b> #{issue.due_date}<br/>
        <hr/>
        <i>#{I18n.t('label_due_notifications_overdue')} <b>** #{days_overdue} **!</b> #{I18n.t('label_due_notifications_urgently')}</i>
      HTML
      [title, body]
    end

    def self.before()
      date_str = Time.zone.now.strftime('%Y-%m-%d %H:%M')
      title = "#{I18n.t('label_due_notifications_start_alerts')}!!!"
      body = <<~HTML
        <hr/>
          <b>📢📢📢 --> -- > --> #{I18n.t('label_due_notifications_start_alerts')} - #{date_str} <-- <-- <-- 📢📢📢</b>
        <hr/>
      HTML
      [title, body]
    end

    def self.after()
      title = "#{I18n.t('label_due_notifications_end_alerts')}!!!"
      body = <<~HTML
        <hr/>
          <b>📢📢📢 --> -- > --> #{I18n.t('label_due_notifications_end_alerts')} <-- <-- <-- 📢📢📢</b>
        <hr/>
      HTML
      [title, body]
    end
  end
end