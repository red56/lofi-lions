class MasterText < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true
end
