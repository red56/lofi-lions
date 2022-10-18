# frozen_string_literal: true

class CreateLocalizedTexts < ActiveRecord::Migration
  def change
    create_table :localized_texts do |t|
      t.integer :master_text_id
      t.integer :language_id
      t.text :text, default: ""
      t.text :comment, default: ""
      t.boolean :needs_review, default: false

      t.timestamps
    end
    add_index :localized_texts, [:language_id, :master_text_id], name: "index_language_id_master_text_id_unqiue", unique: true
    add_index :localized_texts, [:master_text_id], name: "index_master_text_id"
    add_index :localized_texts, [:language_id], name: "index_language_id"
  end
end
