class View < ActiveRecord::Base

  belongs_to :project, inverse_of: :views
  has_many :key_placements, -> { order 'position asc' }, inverse_of: :view, dependent: :destroy
  has_many :master_texts, through: :key_placements
  has_many :localized_texts, through: :master_texts

  validates :project_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :project_id

  default_scope { order('name asc') }

  def keys
    @keys ||= master_texts.collect{|mt| mt.key}.join("\n")
  end

  def keys= new_keys
    key_placements.destroy_all
    @keys = nil
    new_keys.split(%r{\s*\n+\s*}).each_with_index do |key, index|
      key_placements << KeyPlacement.new(master_text: MasterText.find_by_key(key), position: index+1)
    end
  end

  def reload
    @keys = nil
    super
  end
end
