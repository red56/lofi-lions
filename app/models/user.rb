class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable,
      :recoverable, :rememberable, :trackable, :validatable
  # Other devise modules available are.
  # :confirmable, :lockable, :timeoutable and :omniauthable and :registerable
end
