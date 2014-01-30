class MasterText < ActiveRecord::Base

  has_many :localized_texts

  validates :key, presence: true, uniqueness: true
  validates :text, presence: true
end
