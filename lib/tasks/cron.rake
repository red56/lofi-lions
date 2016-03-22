namespace :cron do
  task translation_status_email: [:environment] do
    admin_emails = User.admins.map(&:email)
    CronMailer.translation_status_report(admin_emails).deliver
  end

  WEEKLY_TASKS = [
      'cron:translation_status_email',
  ]
  task if_monday: [:environment] do
    if Date.today.monday?
      WEEKLY_TASKS.each { |task_name| Rake::Task[task_name].invoke }
    end
  end
end
