class MakeTextsPluralizable < ActiveRecord::Migration
  def change
    add_column :master_texts, :pluralizable, :boolean, default: false
    add_column :master_texts, :one, :text, default: ''
    rename_column :master_texts, :text, :other

    add_column :localized_texts, :zero, :text, default: ''
    add_column :localized_texts, :one, :text, default: ''
    add_column :localized_texts, :two, :text, default: ''
    add_column :localized_texts, :few, :text, default: ''
    add_column :localized_texts, :many, :text, default: ''
    rename_column :localized_texts, :text, :other
    add_column :localized_texts, :needs_entry, :boolean

    add_column :languages, :pluralizable_label_zero, :string, default: ''
    add_column :languages, :pluralizable_label_one, :string, default: ''
    add_column :languages, :pluralizable_label_two, :string, default: ''
    add_column :languages, :pluralizable_label_few, :string, default: ''
    add_column :languages, :pluralizable_label_many, :string, default: ''
    add_column :languages, :pluralizable_label_other, :string, default: ''
  end
end
