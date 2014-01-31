class Language < ActiveRecord::Base

  has_many :localized_texts, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
