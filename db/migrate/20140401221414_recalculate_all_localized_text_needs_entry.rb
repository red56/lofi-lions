class RecalculateAllLocalizedTextNeedsEntry < ActiveRecord::Migration
  def up
    LocalizedText.all.each { |localized_text| localized_text.save! }
  end
end
