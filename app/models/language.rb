class Language < ActiveRecord::Base

  def self.plurals
    [:zero, :one, :two, :few, :many, :other]
  end

  def self.plurals_fields
    @plurals_fields ||= plurals.map { |form| [form, "pluralizable_label_#{form}".to_sym] }
  end

  has_many :localized_texts, inverse_of: :language, dependent: :destroy
  accepts_nested_attributes_for :localized_texts

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  alias_attribute :to_param, :code
  alias_attribute :to_s, :name

  # Our canonical "english" text -- used when exporting the master texts to localization files
  def self.en
    Language.new(code: "en", name: "English (fallback)", pluralizable_label_one: "One", pluralizable_label_other: "Other")
  end

  def plurals
    @plurals ||= Hash[active_plurals]
  end

  # Replace with #active_plurals_with_labels functionality once the UI for entering pluralizable labels
  # for languages has been implemented.
  def active_plurals
    active_plurals_without_labels
  end

  def active_plurals_without_labels
    Language.plurals_fields.map { |form, field| [form, form.to_s] }
  end

  def active_plurals_with_labels
    Language.plurals_fields.reject { |form, field| self[field].blank? }.map { |form, field| [form, self[field]] }
  end
end
