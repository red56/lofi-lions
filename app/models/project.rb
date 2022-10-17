class Project < ApplicationRecord

  has_many :master_texts, inverse_of: :project, dependent: :destroy
  has_many :views, inverse_of: :project, dependent: :destroy
  has_many :localized_texts, through: :master_texts
  has_many :project_languages, inverse_of: :project
  has_many :languages, through: :project_languages
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation do
    self.slug = self.class.slugify(name)
  end

  def self.slugify(s)
    s.downcase.parameterize.underscore
  end

  def to_s
    "#{name} Project"
  end
  def master_texts_impersonating_localized_texts
    master_texts.order(:key).map { |master_text| MasterTextImpersonatingLocalizedText.new(master_text) }
  end

  def recalculate_counts!
    project_languages.each do |project_language|
      project_language.recalculate_counts!
    end
  end

  def word_count
    master_texts.sum("word_count")
  end
end
