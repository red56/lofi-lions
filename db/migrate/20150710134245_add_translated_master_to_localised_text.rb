class AddTranslatedMasterToLocalisedText < ActiveRecord::Migration
  def change
    add_column :localized_texts, :translated_from, :text
    add_column :localized_texts, :translated_at, :datetime
  end
end
