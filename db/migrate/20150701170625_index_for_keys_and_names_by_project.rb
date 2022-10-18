# frozen_string_literal: true

class IndexForKeysAndNamesByProject < ActiveRecord::Migration
  def change
    add_index :master_texts, [:key, :project_id], unique: true
    add_index :views, [:name, :project_id], unique: true
  end
end
