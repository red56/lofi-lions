class Language < ActiveRecord::Base

  has_many :localized_texts, inverse_of: :language, dependent: :destroy
  accepts_nested_attributes_for :localized_texts

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  alias_attribute :to_param, :code
  alias_attribute :to_s, :name

  def plurals
    @plurals ||= Hash[[:zero, :one, :two, :few, :many, :other].collect do |plural_form|
      plural_field = "pluralizable_label_#{plural_form}".to_sym
      [plural_form, self[plural_field]]unless self[plural_field].blank?
    end.compact]
  end
end
