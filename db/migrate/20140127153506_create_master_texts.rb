class CreateMasterTexts < ActiveRecord::Migration
  def change
    create_table :master_texts do |t|
      t.string :key
      t.text :text
      t.text :comment

      t.timestamps
    end
  end
end
