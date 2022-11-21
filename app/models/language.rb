# frozen_string_literal: true

class Language < ApplicationRecord
  PLURAL_FORMS = [:zero, :one, :two, :few, :many, :other].freeze
  PLURAL_FORMS_WITH_FIELDS = PLURAL_FORMS.map { |form| [form, "pluralizable_label_#{form}".to_sym] }.freeze

  has_many :project_languages, inverse_of: :language, dependent: :destroy
  has_many :localized_texts, through: :project_languages
  has_many :users, through: :project_languages
  has_many :projects, through: :project_languages

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  alias_attribute :to_param, :code
  alias_attribute :to_s, :name

  # Our canonical "english" text -- used when exporting the master texts to localization files
  def self.for_master_texts
    Language.new(code: "en", name: "English (fallback)",
                 pluralizable_label_one: "One", pluralizable_label_other: "Other").tap do |language|
      def language.is_master_text?
        true
      end
    end
  end

  XX_CODE_FOR_TESTING = "xx"

  def self.xx_for_testing
    Language.new(code: XX_CODE_FOR_TESTING, name: "With xx replacements (for testing)",
                 pluralizable_label_one: "One", pluralizable_label_other: "Other")
  end

  def plural_forms_with_fields
    @plurals ||= Hash[PLURAL_FORMS_WITH_FIELDS.reject { |form, field| self[field].blank? }.map { |form, field|
                        [form, self[field]]
                      } ]
  end

  def is_master_text?
    false
  end

  def code_for_google
    return "zh-CN" if code == "zh"

    code
  end

  def code_for_top_level_rails_hash
    return "en" if code == XX_CODE_FOR_TESTING

    code
  end
end
