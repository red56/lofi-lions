# frozen_string_literal: true

class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.string :name, nil: false
      t.text :comments

      t.timestamps
    end
  end
end
