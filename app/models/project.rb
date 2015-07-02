class Project < ActiveRecord::Base

  has_many :master_texts, inverse_of: :project, dependent: :destroy
  has_many :views, inverse_of: :project, dependent: :destroy
  has_many :localized_texts, through: :master_texts

  validates :name, presence: true

  def slug
    name.parameterize.underscore
  end
end
