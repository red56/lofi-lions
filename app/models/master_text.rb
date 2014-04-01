class MasterText < ActiveRecord::Base

  has_many :localized_texts, inverse_of: :master_text, dependent: :destroy

  validates :key, presence: true, uniqueness: true
  validates :many, presence: true

  def text= text
    self.many = text
  end
  def text
    raise Exception.new("Don't use text when pluralizable") if self.pluralizable
    self.many
  end
  def text_changed?
    return true if self.many_changed?
    return true if self.one_changed?
    return true if self.pluralizable_changed?
    false
  end
end
