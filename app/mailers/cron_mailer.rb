# frozen_string_literal: true

class CronMailer < ApplicationMailer
  default from: ENV["CRON_EMAIL_FROM"] || "cron@example.com"

  def translation_status_report
    @languages = Language.includes(:localized_texts).order(:name)
    mail(to: admins, subject: "Translation status #{Date.today.to_s(:long)}")
  end

  protected

  def admins
    admin_users.map(&:email)
  end

  def admin_users
    User.admins
  end
end
