
namespace :cron do
  task translation_status_email: [:environment] do
    CronMailer.translation_status_report.deliver
  end

  task weekly: [
    :translation_status_email
    ] do
  end
end