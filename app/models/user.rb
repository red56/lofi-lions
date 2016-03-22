require 'securerandom'

class User < ActiveRecord::Base
  devise :database_authenticatable,
      :recoverable, :rememberable, :trackable, :validatable
  # Other devise modules available are.
  # :confirmable, :lockable, :timeoutable and :omniauthable and :registerable

  has_and_belongs_to_many :project_languages

  scope :admins, -> { where(is_administrator: true) }
  scope :send_admininistrator_emails, -> { where(send_admininistrator_emails: true) }

  def self.admin_emails
    self.send_admininistrator_emails.map(&:email)
  end

  def to_s
    "User(#{email})"
  end

  def randomize_password
    self.password = self.class.random_password
  end
  def self.random_password
    SecureRandom.hex
  end
end
