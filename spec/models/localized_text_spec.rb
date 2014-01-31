require 'spec_helper'

describe LocalizedText do
  describe "validations" do
    let(:localized_text) { build(:localized_text) }
    it "basically works" do
      localized_text.should be_valid
    end
    it "requires master_text_id" do
      localized_text.master_text_id = nil
      localized_text.should_not be_valid
    end
    it "requires language id" do
      localized_text.language_id = nil
      localized_text.should_not be_valid
    end
  end

  describe LocalizedText::Enforcer do
    let(:master_text) { create(:master_text) }
    let(:other_master_text) { create(:master_text) }
    let(:language) { create(:language) }
    let(:other_language) { create(:language) }
    before { master_text; language }
    describe "master text created" do
      it " it creates blank localized texts for each language" do
        master_text; language
        expect {
          LocalizedText::Enforcer.new.master_text_created(master_text)
        }.to change { LocalizedText.count }.by(1)
      end
    end
    describe "master text changed" do
      it "it doesnt do anything to blank localized texts" do
        blank_localized_text = create(:localized_text, master_text: master_text, language: language)
        expect {
          LocalizedText::Enforcer.new.master_text_changed(master_text)
        }.not_to change { blank_localized_text.reload; [
            LocalizedText.count,
            blank_localized_text.needs_review,
            blank_localized_text.text]
        }
      end
      it "makes filled localized texts as needing review" do
        localized_text= create(:localized_text, master_text: master_text, language: language, text: "Quelque chose d'ancien")
        LocalizedText::Enforcer.new.master_text_changed(master_text)
        expect {
          LocalizedText::Enforcer.new.master_text_changed(master_text)
        }.not_to change { [LocalizedText.count,localized_text.reload.text]
        }
        localized_text.reload.needs_review.should be_true
      end
    end

    describe "language created" do
      it "creates blank localized texts for each master text" do
        expect {
          LocalizedText::Enforcer.new.language_created(language)
        }.to change { LocalizedText.count}.by(1)
      end
    end
  end
end
