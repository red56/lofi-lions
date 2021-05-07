class ProjectLanguage < ActiveRecord::Base

  belongs_to :project, inverse_of: :project_languages
  belongs_to :language, inverse_of: :project_languages
  has_many(:localized_texts,
      lambda{ joins(:master_text).order('LOWER(master_texts.key)') },
      inverse_of: :project_language, dependent: :destroy,
  )
  has_and_belongs_to_many :users

  accepts_nested_attributes_for :localized_texts

  validates_presence_of :project_id

  delegate :code, :code_for_google, to: :language, prefix: true

  def recalculate_counts!
    self.update!(
        need_review_count: self.localized_texts.needing_review.count,
        need_entry_count: self.localized_texts.needing_entry.count,
        need_review_word_count: self.localized_texts.needing_review.sum('master_texts.word_count'),
        need_entry_word_count: self.localized_texts.needing_entry.sum('master_texts.word_count'),
    )
  end

  def needs_review_or_entry_count
    need_review_count + need_entry_count
  end

  # could be improved -- needs specific tests
  # should return an arry of localized texts ordered by key. It's not obvious to me right now why you need a fallback
  # -- there should never be a situation (er, except maybe in tests with dodgy fixtures) where there is no
  # LocalizedText# for a given existing MasterText + Language. See LocalizedTextEnforcer# for details
  def localized_texts_with_fallback
    MasterText.where(project_id: project.id).order(:key).map { |mt| _localized_text_with_fallback(mt) }
  end

  # only used as helper to the above. needs refactoring
  def _localized_text_with_fallback(master_text)
    master_text.localized_texts.where(project_language: self).first || MasterTextImpersonatingLocalizedText.new(master_text)
  end

  def to_s
    "#{project.name} - #{language.name}"
  end

  def next_localized_text(after_key = '', all: false)
    candidates = all ? localized_texts.limit(1) : localized_texts.needs_review_or_entry.limit(1)
    if after_key.present?
      candidates.where('key > ?', after_key).first
    else
      candidates.first
    end
  end

  def google_translate_missing
    to_translate = localized_texts.needing_entry.includes(:master_text)
    return 0 unless to_translate.to_a.present?
    translations = EasyTranslate.translate(
      to_translate.map(&:original_text),
      from: "en",
      to: language_code_for_google,
      format: 'text'
    )
    translations.zip(to_translate) do |translation, localized_text|
      localized_text.google_translated!(translation)
    end
    recalculate_counts!
    translations.length
  end

  def self.auto_translate_all
    report = []
    report << "Auto translate"
    all.each do |project_language|
      n = project_language.google_translate_missing
      report << "* [%5s] #{project_language}" % [n] if n > 0
    end
    puts report.join("\n")
  end
end
