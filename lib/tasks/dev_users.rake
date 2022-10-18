namespace :dev do
  task dev_users: :environment do
    raise Exception.new("Should only do in development!") unless (Rails.env.development? || Rails.env.staging?)

    ensure_users "password"
    User.all.each { |u| u.update_attributes(password: "password") }
  end

  def ensure_users password
    ensure_admin_user "admin@example.com", password
    ensure_user "test@example.com", password
    puts "ensured admin@example.com and test@example.com with password '#{password}'"
  end

  def ensure_user email, password = "password", options = {}
    admin = options[:is_administrator] || false
    u = User.find_by_email(email)
    if u
      u.password = password
    else
      u = User.new(email: email, password: password)
    end
    u.is_administrator = admin
    u.save!
    u
  end

  def ensure_admin_user email, password = "password"
    ensure_user email, password = password, is_administrator: true
  end
end
