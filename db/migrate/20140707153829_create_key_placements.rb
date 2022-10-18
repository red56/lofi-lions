# frozen_string_literal: true

class CreateKeyPlacements < ActiveRecord::Migration
  def change
    create_table :key_placements do |t|
      t.references :master_text, index: true
      t.references :view, index: true
      t.integer :position

      t.timestamps
    end
  end
end
