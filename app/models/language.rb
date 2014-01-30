class Language < ActiveRecord::Base

  has_many :localized_texts

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
