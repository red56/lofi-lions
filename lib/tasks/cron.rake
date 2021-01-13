namespace :cron do
  task translation_status_email: [:environment] do
    CronMailer.translation_status_report(User.admin_emails).deliver_now
  end
  task translator_update: [:environment] do
    User.includes(:project_languages).select { |u| u.project_languages > 0 }.each do |translator|
      CronMailer.translator_update(translator, User.admin_emails).deliver_now
    end
  end

  WEEKLY_TASKS = [
      'cron:translation_status_email',
      'cron:translator_update'
  ]
  task if_monday: [:environment] do
    if Date.today.monday?
      WEEKLY_TASKS.each { |task_name| Rake::Task[task_name].invoke }
    end
  end
end
