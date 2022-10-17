class CreateMasterTexts < ActiveRecord::Migration
  def change
    create_table :master_texts do |t|
      t.string :key, default: ""
      t.text :text, default: ""
      t.text :comment, default: ""

      t.timestamps
    end
  end
end
