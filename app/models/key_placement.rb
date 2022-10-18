# frozen_string_literal: true

class KeyPlacement < ApplicationRecord
  belongs_to :master_text, inverse_of: :key_placements, optional: false
  belongs_to :view, inverse_of: :key_placements, optional: false
end
