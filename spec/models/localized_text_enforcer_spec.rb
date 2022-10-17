require "rails_helper"

describe LocalizedTextEnforcer, type: :model do
  let(:project) { create(:project) }
  let(:master_text) { create(:master_text, project: project) }
  let(:other_master_text) { create(:master_text, project: project) }
  let(:language) { create(:language, :type_1_english) }
  let(:other_language) { create(:language) }
  let(:project_language) { create(:project_language, project: project, language: language) }
  let(:other_project_language) { create(:project_language, project: project, language: other_language) }

  after do
    MasterText.delete_all
  end

  describe "Enforcer" do
    before { master_text; project_language }
    describe "master text created" do
      it " it creates blank localized texts for each project_language" do
        master_text; project_language
        expect {
          LocalizedTextEnforcer.new.master_text_created(master_text)
        }.to change { LocalizedText.count }.by(1)
      end
    end
    describe "master text changed" do
      it "it doesnt do anything to blank localized texts" do
        blank_localized_text = create(:localized_text, master_text: master_text, project_language: project_language)
        expect {
          LocalizedTextEnforcer.new.master_text_changed(master_text)
        }.not_to change { blank_localized_text.reload; [
                LocalizedText.count,
                blank_localized_text.needs_review,
                blank_localized_text.text]
            }
      end
      it "makes filled localized texts as needing review" do
        localized_text= create(:localized_text, master_text: master_text, project_language: project_language, text: "Quelque chose d'ancien")
        LocalizedTextEnforcer.new.master_text_changed(master_text)
        expect {
          LocalizedTextEnforcer.new.master_text_changed(master_text)
        }.not_to change { [LocalizedText.count, localized_text.reload.text]
            }
        expect(localized_text.reload.needs_review).to be_truthy
      end
    end

    describe "project_language created" do
      it "creates blank localized texts for each master text" do
        expect {
          LocalizedTextEnforcer.new.project_language_created(project_language)
        }.to change { LocalizedText.count }.by(1)
      end
      it "calls #recalculates_counts!" do
        expect(project_language).to receive(:recalculate_counts!)
          LocalizedTextEnforcer.new.project_language_created(project_language)
      end
    end
  end

  describe LocalizedTextEnforcer::MasterTextCrudder do

    describe "master text created" do
      it " it creates blank localized texts for each project_language" do
        project_language
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(build :master_text, project: project)
        expect {
          mt_crudder.save
        }.to change { LocalizedText.count }.by(1)
      end
      it "should do something if update called on a new_record" do
        project_language
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(build :master_text, project: project)
        expect {
          mt_crudder.update(text: "flong")
        }.to change { LocalizedText.count }.by(1)
      end
      it "calls #recalculate_counts!" do
        expect(project).to receive(:recalculate_counts!)
        LocalizedTextEnforcer::MasterTextCrudder.new(build :master_text, project: project).save!
      end
    end
    describe "master text changed" do
      it "it doesnt do anything to blank localized texts" do
        project_language
        blank_localized_text = create(:localized_text, master_text: master_text, project_language: project_language)
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        expect {
          mt_crudder.update(text: "flong")
        }.not_to change { blank_localized_text.reload; [
                LocalizedText.count,
                blank_localized_text.needs_review,
                blank_localized_text.text]
            }
        expect(master_text.reload.text).to eq("flong")
      end
      it "makes filled localized texts as needing review" do
        localized_text= create(:localized_text, master_text: master_text, project_language: project_language, text: "Quelque chose d'ancien")
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        expect {
          mt_crudder.update(text: "flong")
        }.not_to change { [LocalizedText.count, localized_text.reload.text] }
        expect(localized_text.reload.needs_review).to be_truthy
        expect(master_text.reload.text).to eq("flong")
      end
      it "doesn't mark as needing review if text unchanged" do
        localized_text= create(:localized_text, master_text: master_text, project_language: project_language, text: "Quelque chose d'ancien")
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        expect {
          mt_crudder.update(key: "flong")
        }.not_to change { [LocalizedText.count, localized_text.reload.text, localized_text.reload.needs_review] }
        expect(master_text.reload.key).to eq("flong")
      end
      it "should do something if save called on a exisitng record" do
        project_language
        localized_text= create(:localized_text, master_text: master_text, project_language: project_language, text: "Quelque chose d'ancien")
        mt_crudder = LocalizedTextEnforcer::MasterTextCrudder.new(master_text)
        master_text.text = "flong"
        expect {
          mt_crudder.save
        }.not_to change { [LocalizedText.count, localized_text.reload.text] }
        expect(localized_text.reload.needs_review).to be_truthy
        expect(master_text.reload.text).to eq("flong")

      end

    end

    describe "master text create or update" do
      let(:key) { "MyKey" }
      let(:text) { "This is my key" }

      it "creates a new master text for key if none exists" do
        mt = nil
        expect {
          mt = LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, text, project.id)
        }.to change { MasterText.count }.by(1)
        expect(mt).to be_instance_of MasterText
        expect(mt.key).to eq(key)
        expect(mt.text).to eq(text)
        expect(mt.format).to eq(MasterText::PLAIN_FORMAT)
      end

      it "doesn't touch an existing master text with same value" do
        original = create(:master_text, key: key, text: text, project: project)
        expect {
          LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, text, project.id)
        }.not_to change { original.reload.updated_at }
      end

      it "raises an exception if master text fails validation" do
        expect {
          LocalizedTextEnforcer::MasterTextCrudder.create_or_update!(key, nil, project.id)
        }.to raise_error ActiveRecord::RecordInvalid
      end

      describe "with changed value" do
        let(:new_text) { "This is not my key" }
        let!(:mt) { create(:master_text, project: project, key: key, text: text) }
        it "updates the master text with the new value" do
          expect {
            LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, new_text, project.id)
          }.to change { [mt.reload.updated_at, mt.reload.text] }
        end

        it "marks filled localized text as needing review" do
          localized_text= create(:localized_text, master_text: mt, project_language: project_language, text: "Quelque chose d'ancien")
          expect {
            LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, new_text, project.id)
          }.not_to change { [LocalizedText.count, localized_text.reload.text] }
          expect(localized_text.reload.needs_review).to be_truthy
          expect(mt.reload.text).to eq(new_text)
        end
      end

      context "with a key ending _md" do
        let(:key) { "MyText_md" }
        it "creates a new master text with type markdown for key if none exists" do
          mt = nil
          expect {
            mt = LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, text, project.id)
          }.to change { MasterText.count }.by(1)
          expect(mt.format).to eq(MasterText::MARKDOWN_FORMAT)
        end
        it "doesn't touch an existing master text with same value" do
          original = create(:master_text, key: key, text: text, project: project)
          expect {
            LocalizedTextEnforcer::MasterTextCrudder.create_or_update(key, text, project.id)
          }.not_to change { original.reload.updated_at }
        end
      end


    end
  end

  describe LocalizedTextEnforcer::ProjectLanguageCreator do

    describe "project_language created" do
      it "creates blank localized texts for each master text" do
        master_text
        l_crudder = LocalizedTextEnforcer::ProjectLanguageCreator.new(build(:project_language, project: project))
        expect {
          l_crudder.save
        }.to change { LocalizedText.count }.by(1)
      end
      it "returns true when saving" do
        l_crudder = LocalizedTextEnforcer::ProjectLanguageCreator.new(build(:project_language, project: project))
        expect(l_crudder.save).to be_truthy
      end
      it "returns false when not saving" do
        l_crudder = LocalizedTextEnforcer::ProjectLanguageCreator.new(build(:project_language, project: nil))
        expect(l_crudder.save).to be_falsey
      end
    end

  end

  describe LocalizedTextEnforcer::LanguageCreator do

    describe "language created" do
      it "creates project_languages for each project" do
        master_text
        l_crudder = LocalizedTextEnforcer::LanguageCreator.new(build(:language))
        expect {
          l_crudder.save
        }.to change { ProjectLanguage.count }.by(Project.count)
      end
      it "creates blank localized texts for each master text" do
        master_text
        l_crudder = LocalizedTextEnforcer::LanguageCreator.new(build(:language))
        expect {
          l_crudder.save
        }.to change { LocalizedText.count }.by(1)
      end
      it "returns true when saving" do
        l_crudder = LocalizedTextEnforcer::LanguageCreator.new(build(:language))
        expect(l_crudder.save).to be_truthy
      end
      it "returns false when not saving" do
        l_crudder = LocalizedTextEnforcer::LanguageCreator.new(build(:language, name: ""))
        expect(l_crudder.save).to be_falsey
      end
    end

  end
end
