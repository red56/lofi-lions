# frozen_string_literal: true

class AddFormatToMasterTexts < ActiveRecord::Migration
  def change
    add_column :master_texts, :format, :string, default: "plain"
  end
end
