class CronMailer < ActionMailer::Base
  layout 'mailer'
  default from: ENV["CRON_EMAIL_FROM"] || "cron@example.com"

  def translation_status_report(admin_emails)
    @languages = Language.includes(:localized_texts).order(:name)
    mail(to: admin_emails, subject: "Translation status #{Date.today.to_s(:long)}")
  end

  def translator_update(translator, admin_emails=[])
    @project_languages = translator.project_languages
    mail(to: translator.email, cc: admin_emails)
  end

end
