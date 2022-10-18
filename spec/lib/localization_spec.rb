# frozen_string_literal: true

require "rails_helper"

describe Localization do
  let(:project) { create :project }

  describe "create_master_texts" do
    it "works with non pluralized" do
      expect {
        Localization.create_master_texts([Localization.new("somekey", "something new in sandwiches")], project)
      }.to change { MasterText.count }.by(1)
    end

    it "works with pluralized" do
      expect {
        Localization.create_master_texts([Localization.new("somekey", one: "one sandwich", other: "%d sandwiches")],
                                         project)
      }.to change { MasterText.count }.by(1)
      expect(MasterText.last.pluralizable).to be_truthy
      expect(MasterText.last.one).to eq("one sandwich")
      expect(MasterText.last.other).to eq("%d sandwiches")
    end

    it "invokes recalculate_counts!" do
      expect(project).to receive(:recalculate_counts!)
      Localization.create_master_texts([Localization.new("somekey", "something new in sandwiches")], project)
    end
  end

  describe "create_localized_texts" do
    let(:language) { project_language.language }
    let(:project) { create :project }
    let(:project_language) { create :project_language, project: project, language: create(:language) }

    context "with master key" do
      before { master_text }

      let(:master_text) { create :master_text, key: "somekey", project: project }

      it "creates" do
        expect {
          Localization.create_localized_texts(language, [Localization.new("somekey", "something new in sandwiches")], project.id)
        }.to change { LocalizedText.count }.by(1)
        expect(LocalizedText.last.language).to eq(language)
      end

      it "returns no errors" do
        result = Localization.create_localized_texts(language, [Localization.new("somekey",
                                                                                 "something new in sandwiches")], project.id)
        expect(result).to be_empty
      end

      it "calls #recalculates_counts!" do
        expect(ProjectLanguage).to receive(:where).and_return([project_language])
        expect(project_language).to receive(:recalculate_counts!)
        Localization.create_localized_texts(language, [Localization.new("somekey", "one sandwich")],
                                            project.id)
      end

      it "creates pluralized forms" do
        expect {
          Localization.create_localized_texts(language, [Localization.new("somekey", one: "one sandwich",
                                                                                     two: "two sandwiches", other: "%d sandwiches")], project.id)
        }.to change { LocalizedText.count }.by(1)
        localized_text = LocalizedText.last
        expect(localized_text.one).to eq("one sandwich")
        expect(localized_text.two).to eq("two sandwiches")
        expect(localized_text.other).to eq("%d sandwiches")
      end

      context "when already exists" do
        before { localized_text }

        let(:localized_text) {
          create :localized_text, project_language: project_language, master_text: master_text,
                                  other: "some value"
        }

        it "updates" do
          expect {
            Localization.create_localized_texts(language, [Localization.new("somekey", one: "one sandwich",
                                                                                       two: "two sandwiches", other: "%d sandwiches")], project.id)
          }.not_to change { LocalizedText.count }
          localized_text.reload
          expect(localized_text.one).to eq("one sandwich")
          expect(localized_text.two).to eq("two sandwiches")
          expect(localized_text.other).to eq("%d sandwiches")
        end
      end
    end

    context "without master text" do
      it "doesn't create but returns errors" do
        expect {
          result = Localization.create_localized_texts(language, [Localization.new("somekey",
                                                                                   "something new in sandwiches")], project.id)
          expect(result).not_to be_empty
        }.not_to change { LocalizedText.count }
      end
    end

    context "without master text in specified project" do
      let!(:master_text) { create :master_text, key: "somekey" }

      it "doesn't create but returns errors" do
        expect {
          result = Localization.create_localized_texts(language, [Localization.new("somekey",
                                                                                   "something new in sandwiches")], project.id)
          expect(result).not_to be_empty
        }.not_to change { LocalizedText.count }
      end
    end
  end
end
