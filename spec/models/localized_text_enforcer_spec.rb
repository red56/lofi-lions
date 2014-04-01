require 'spec_helper'

describe LocalizedTextEnforcer do
  let(:master_text) { create(:master_text) }
  let(:other_master_text) { create(:master_text) }
  let(:language) { create(:language, :type_1_english) }
  let(:other_language) { create(:language) }

  after do
    MasterText.delete_all
  end

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

    describe "master text create or update" do
      let(:key) { "MyKey" }
      let(:text) { "This is my key" }

      it "creates a new master text for key if none exists" do
        mt = nil
        expect {
          mt = LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, text)
        }.to change { MasterText.count }.by(1)
        mt.should be_instance_of MasterText
        mt.key.should == key
        mt.text.should == text
      end

      it "doesn't touch an existing master text with same value" do
        original = create(:master_text, key: key, text: text)
        expect {
          LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, text)
        }.not_to change { original.reload.updated_at }
      end

      it "raises an exception if master text fails validation" do
        expect {
          LocalizedTextEnforcer::MasterTextCrudder.create_or_update!(key, nil)
        }.to raise_error ActiveRecord::RecordInvalid
      end

      describe "with changed value" do
        let(:new_text) { "This is not my key" }
        let!(:mt)  { create(:master_text, key: key, text: text) }
        it "updates the master text with the new value" do
          expect {
            LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, new_text)
          }.to change { [mt.reload.updated_at, mt.reload.text] }
        end

        it "marks filled localized text as needing review" do
          localized_text= create(:localized_text, master_text: mt, language: language, text: "Quelque chose d'ancien")
          expect {
            LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, new_text)
          }.not_to change { [LocalizedText.count, localized_text.reload.text] }
          localized_text.reload.needs_review.should be_true
          mt.reload.text.should == new_text
        end
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
      it "returns true when saving" do
        l_crudder = LocalizedTextEnforcer::LanguageCreator.new(build(:language))
        l_crudder.save.should be_true
      end
      it "returns false when not saving" do
        l_crudder = LocalizedTextEnforcer::LanguageCreator.new(build(:language, name: ''))
        l_crudder.save.should be_false
      end
    end

  end
end