class MailPreview < MailView
  # Navigate to http://localhost:3000/mail_view
  # to see a preview of the emails you include here

  def translation_status_report
    CronMailer.translation_status_report(['tim@example.com'])
  end

  def translator_update
    translator = User.includes(:project_languages).detect{|u| u.project_languages.length > 1}
    CronMailer.translator_update(translator, ['tim@example.com'])
  end
end
