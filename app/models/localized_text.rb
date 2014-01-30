class LocalizedText < ActiveRecord::Base
  belongs_to :master_text, inverse_of: :localized_texts
  belongs_to :language, inverse_of: :localized_texts

  validates :master_text_id, presence: true
  validates :language_id, presence: true
end
