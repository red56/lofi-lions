class ProjectLanguage < ActiveRecord::Base

  belongs_to :project, inverse_of: :project_languages
  belongs_to :language, inverse_of: :project_languages
  has_many :localized_texts, inverse_of: :project_language, dependent: :destroy
  has_and_belongs_to_many :users

  accepts_nested_attributes_for :localized_texts

  validates_presence_of :project_id

  def recalculate_counts!
    self.update!(
        need_review_count: self.localized_texts.where(needs_review: true, needs_entry: false).count,
        need_entry_count: self.localized_texts.where(needs_entry: true).count,)
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
    master_text.localized_texts.where(project_language: self).first || MasterTextFallback.new(master_text)
  end

  # Our canonical "english" text -- used when exporting the master texts to localization files
  def self.for_master_texts(language, project)
    ProjectLanguage.new(language: language, project: project).tap do |plang|
      def plang.is_master_text?
        true
      end
    end
  end

  def is_master_text?
    false
  end
end
