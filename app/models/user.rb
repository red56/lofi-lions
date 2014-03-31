class User < ActiveRecord::Base
  devise :database_authenticatable,
      :recoverable, :rememberable, :trackable, :validatable
  # Other devise modules available are.
  # :confirmable, :lockable, :timeoutable and :omniauthable and :registerable

  def to_s
    "User(#{email})"
  end
end
