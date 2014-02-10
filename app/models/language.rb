class Language < ActiveRecord::Base

  has_many :localized_texts, dependent: :destroy
  accepts_nested_attributes_for :localized_texts

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  alias_attribute :to_param, :code
  alias_attribute :to_s, :name
end
