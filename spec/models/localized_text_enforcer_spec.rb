require 'spec_helper'

describe LocalizedTextEnforcer do
  let(:master_text) { create(:master_text) }
  let(:other_master_text) { create(:master_text) }
  let(:language) { create(:language) }
  let(:other_language) { create(:language) }
  describe "Enforcer" do
    before { master_text; language }
    describe "master text created" do
      it " it creates blank localized texts for each language" do
        master_text; language
        expect {
          LocalizedTextEnforcer.new.master_text_created(master_text)
        }.to change { LocalizedText.count }.by(1)
      end
    end
    describe "master text changed" do
      it "it doesnt do anything to blank localized texts" do
        blank_localized_text = create(:localized_text, master_text: master_text, language: language)
        expect {
          LocalizedTextEnforcer.new.master_text_changed(master_text)
        }.not_to change { blank_localized_text.reload; [
            LocalizedText.count,
            blank_localized_text.needs_review,
            blank_localized_text.text]
        }
      end
      it "makes filled localized texts as needing review" do
        localized_text= create(:localized_text, master_text: master_text, language: language, text: "Quelque chose d'ancien")
        LocalizedTextEnforcer.new.master_text_changed(master_text)
        expect {
          LocalizedTextEnforcer.new.master_text_changed(master_text)
        }.not_to change { [LocalizedText.count, localized_text.reload.text]
        }
        localized_text.reload.needs_review.should be_true
      end
    end

    describe "language created" do
      it "creates blank localized texts for each master text" do
        expect {
          LocalizedTextEnforcer.new.language_created(language)
        }.to change { LocalizedText.count }.by(1)
      end
    end
  end

  describe LocalizedTextEnforcer::MasterTextCrudder do

    describe "master text created" do
      it " it creates blank localized texts for each language" do
        language
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(build :master_text)
        expect {
          mt_crudder.save
        }.to change { LocalizedText.count }.by(1)
      end
      it "should do something if update called on a new_record" do
        language
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(build :master_text)
        expect {
          mt_crudder.update(text: "flong")
        }.to change { LocalizedText.count }.by(1)
      end

    end
    describe "master text changed" do
      it "it doesnt do anything to blank localized texts" do
        language
        blank_localized_text = create(:localized_text, master_text: master_text, language: language)
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        expect {
          mt_crudder.update(text: "flong")
        }.not_to change { blank_localized_text.reload; [
            LocalizedText.count,
            blank_localized_text.needs_review,
            blank_localized_text.text]
        }
        master_text.reload.text.should == "flong"
      end
      it "makes filled localized texts as needing review" do
        localized_text= create(:localized_text, master_text: master_text, language: language, text: "Quelque chose d'ancien")
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        expect {
          mt_crudder.update(text: "flong")
        }.not_to change { [LocalizedText.count, localized_text.reload.text] }
        localized_text.reload.needs_review.should be_true
        master_text.reload.text.should == "flong"
      end
      it "doesn't mark as needing review if text unchanged" do
        localized_text= create(:localized_text, master_text: master_text, language: language, text: "Quelque chose d'ancien")
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        expect {
          mt_crudder.update(key: "flong")
        }.not_to change { [LocalizedText.count, localized_text.reload.text, localized_text.reload.needs_review] }
        master_text.reload.key.should == "flong"
      end
      it "should do something if save called on a exisitng record" do
        language
        localized_text= create(:localized_text, master_text: master_text, language: language, text: "Quelque chose d'ancien")
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        master_text.text = "flong"
        expect {
          mt_crudder.save
        }.not_to change { [LocalizedText.count, localized_text.reload.text] }
        localized_text.reload.needs_review.should be_true
        master_text.reload.text.should == "flong"

      end
    end


  end

  describe LocalizedTextEnforcer::LanguageCreator do

    describe "language created" do
      it "creates blank localized texts for each master text" do
        master_text
        l_crudder = LocalizedTextEnforcer::LanguageCreator.new(build(:language))
        expect {
          l_crudder.save
        }.to change { LocalizedText.count }.by(1)
      end
    end

  end
end