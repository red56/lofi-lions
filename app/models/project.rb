class Project < ActiveRecord::Base

  has_many :master_texts, inverse_of: :project, dependent: :destroy
  has_many :views, inverse_of: :project, dependent: :destroy
  has_many :localized_texts, through: :master_texts

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation do
    self.slug = self.class.slugify(name)
  end

  def self.slugify(s)
    s.downcase.parameterize.underscore
  end

end
