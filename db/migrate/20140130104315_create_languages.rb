class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name, default: ''
      t.string :code, default: ''

      t.timestamps
    end
  end
end
