class LocalizedText < ActiveRecord::Base
  belongs_to :master_text, inverse_of: :localized_texts
  belongs_to :language, inverse_of: :localized_texts

  validates :master_text_id, presence: true
  validates :language_id, presence: true


  # makes sure we have the localized texts we deserve
  # # keeping this embeddded in LocalizedText for now... will split out if/when...
  class Enforcer
    #called after a master text is created. Assume no localized texts are created.
    def master_text_created(master_text)
      Language.all.each do |language|
        master_text.localized_texts.create!(language: language)
      end
    end

    #used when a master text is changed. Assume localized texts are all created.
    def master_text_changed(master_text)
      master_text.localized_texts.where('text != ?', '').update_all(needs_review: true)
    end

    def language_created(language)
      MasterText.all.each do |master_text|
        master_text.localized_texts.create!(language: language)
      end
    end


  end
end
