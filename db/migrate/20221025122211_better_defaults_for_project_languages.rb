# frozen_string_literal: true

class BetterDefaultsForProjectLanguages < ActiveRecord::Migration[5.2]
  def change
    change_table :project_languages, bulk: true do |t|
      t.change_default  :need_entry_count, from: nil, to: 0
      t.change_default  :need_review_count, from: nil, to: 0
      t.change_default  :need_entry_word_count, from: nil, to: 0
      t.change_default  :need_review_word_count, from: nil, to: 0
    end
  end
end
