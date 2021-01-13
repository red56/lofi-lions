class UsersController < ApplicationController
  before_action :require_administrator!
  before_action :find_user, only: [:edit, :update]
  before_action :set_users_section

  def index
    @users = User.all.includes(project_languages: [:project, :language]).order(:email)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.randomize_password
    if @user.save
      redirect_to users_path, notice: "#{@user.email} created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to users_path, notice: "#{@user.email} updated"
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(
        :email, :is_administrator, :send_administrator_emails, :is_developer, :edits_master_text,
        project_language_ids: []
    )

  end

  def find_user
    @user = User.find(params[:id])
  end
end
