# frozen_string_literal: true

require "securerandom"

class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  # Other devise modules available are.
  # :confirmable, :lockable, :timeoutable and :omniauthable and :registerable

  has_and_belongs_to_many :project_languages

  scope :admins, -> { where(is_administrator: true) }

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
