class AddWordCountsToProjectLanguages < ActiveRecord::Migration
  def change
    add_column :master_texts, :word_count, :integer
    add_column :project_languages, :need_entry_word_count, :integer
    add_column :project_languages, :need_review_word_count, :integer
  end
end
