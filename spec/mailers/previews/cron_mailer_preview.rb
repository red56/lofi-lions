class CronMailerPreview < ActionMailer::Preview
  # Navigate to http://localhost:3010/rails/mailers
  # to see a preview of the emails you include here

  def translation_status_report
    CronMailer.translation_status_report
  end
end
