class Language < ActiveRecord::Base

  PLURAL_FORMS = [:zero, :one, :two, :few, :many, :other].freeze
  PLURAL_FORMS_WITH_FIELDS = PLURAL_FORMS.map { |form| [form, "pluralizable_label_#{form}".to_sym] }.freeze


  has_many :localized_texts, inverse_of: :language, dependent: :destroy
  accepts_nested_attributes_for :localized_texts
  has_and_belongs_to_many :users

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

  def plural_forms_with_fields
    @plurals ||= Hash[PLURAL_FORMS_WITH_FIELDS.reject { |form, field| self[field].blank? }.map { |form,
            field| [form, self[field]] }]
  end


  # could be improved -- needs specific tests
  # should return an arry of localized texts ordered by key. It's not obvious to me right now why you need a fallback
  # -- there should never be a situation (er, except maybe in tests with dodgy fixtures) where there is no
  # LocalizedText# for a given existing MasterText + Language. See LocalizedTextEnforcer# for details
  def localized_texts_with_fallback(project)
    MasterText.where(project_id: project.id).order(:key).map { |mt| _localized_text_with_fallback(mt) }
  end

  # only used as helper to the above. needs refactoring
  def _localized_text_with_fallback(master_text)
    master_text.localized_texts.where(language: self).first || MasterTextFallback.new(master_text)
  end

  def is_master_text?
    false
  end
end
