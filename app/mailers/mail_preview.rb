class MailPreview < MailView
  # Navigate to http://localhost:3000/mail_view
  # to see a preview of the emails you include here

  def translation_status_report
    CronMailer.translation_status_report
  end
end