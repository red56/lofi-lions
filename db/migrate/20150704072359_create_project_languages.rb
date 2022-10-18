class CreateProjectLanguages < ActiveRecord::Migration
  class LanguageUser < ApplicationRecord
    self.table_name = :languages_users

    belongs_to :user
  end

  def change
    create_table :project_languages do |t|
      t.integer :project_id, null: false
      t.integer :language_id, null: false
      t.integer :need_entry_count
      t.integer :need_review_count

      t.timestamps null: false
    end

    create_table :project_languages_users, id: false do |t|
      t.integer :project_language_id, null: false
      t.integer :user_id, null: false
    end

    add_column :localized_texts, :project_language_id, :integer
    LocalizedText.reset_column_information

    Language.all.each do |language|
      Project.all.each do |project|
        plang = project.project_languages.create!(language: language)
        LanguageUser.where(language_id: language.id).all.each do |luser|
          plang.users << luser.user
        end
        LocalizedText.joins(:master_text).where(language_id: language.id, master_texts: { project_id: project.id })
                     .update_all(project_language_id: plang.id)
        plang.recalculate_counts!
      end
    end

    drop_table :languages_users
    change_column :localized_texts, :project_language_id, :integer, null: false
    remove_column :localized_texts, :language_id, :integer, null: false
  end
end
