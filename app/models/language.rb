class Language < ActiveRecord::Base

  PLURAL_FORMS = [:zero, :one, :two, :few, :many, :other].freeze
  PLURAL_FORMS_WITH_FIELDS = PLURAL_FORMS.map { |form| [form, "pluralizable_label_#{form}".to_sym] }.freeze


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

  def plural_forms_with_fields
    @plurals ||=  Hash[PLURAL_FORMS_WITH_FIELDS.reject { |form, field| self[field].blank? }.map { |form,
        field| [form, self[field]] }]
  end

end
