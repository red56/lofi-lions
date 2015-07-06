class Project < ActiveRecord::Base

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

end
