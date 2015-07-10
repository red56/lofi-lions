class LocalizedText < ActiveRecord::Base
  belongs_to :master_text, inverse_of: :localized_texts
  belongs_to :project_language, inverse_of: :localized_texts
  has_many :views, through: :master_text

  validates :master_text_id, presence: true
  validates :project_language_id, presence: true

  validate do
    self.needs_entry = calculate_needs_entry
  end

  delegate :key, :comment, :pluralizable, to: :master_text
  delegate :text, :one, :other, to: :master_text, prefix: 'original'
  delegate :language, :language_id, to: :project_language

  before_save :update_translated_from

  def text= text
    self.other = text
  end

  def text
    raise Exception.new("Don't use text when pluralizable") if self.pluralizable
    self.other
  end

  # Provides a value or master text fallback for the exporters
  def other_export
    return other unless other.blank?
    original_other
  end

  def calculate_needs_entry
    return self.text.blank? unless pluralizable
    self.language.plural_forms_with_fields.keys.any? { |attr_name| self[attr_name].blank? }
  end

  def update_translated_from
    unless needs_review? || needs_entry?
      self.translated_from = master_text.text
      puts Time.now
      self.translated_at = Time.now
    end
  end
end
