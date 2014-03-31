def stubbed_login_as_admin_user
  ApplicationController.any_instance.stub(user_signed_in?: true, current_user: ensure_admin_user, authenticate_user!: true)
end

def ensure_admin_user
  @user ||= build_stubbed(:user, email: 'admin@example.com', is_administrator: true)
end

def stubbed_login_as_user
  ApplicationController.any_instance.stub(user_signed_in?: true, current_user: ensure_user, authenticate_user!: true)
end

def ensure_user
  @user ||= build_stubbed(:user, email: 'test@example.com')
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
end
