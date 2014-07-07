class KeyPlacement < ActiveRecord::Base
  belongs_to :master_text, inverse_of: :key_placements
  belongs_to :view, inverse_of: :key_placements
end
