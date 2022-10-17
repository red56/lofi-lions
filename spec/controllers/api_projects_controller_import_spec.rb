require "rails_helper"

describe Api::ProjectsController, type: :controller do
  let(:file_upload) { fixture_file_upload(file_path, "application/octet-stream") }
  let!(:selected_project) { create(:project) }
  before {bypass_rescue}
  context "without auth token" do
    it "should fail with 401?"
  end
  context "with invalid auth token" do
    it "should fail with 401?"
  end

  describe "iOS" do
    let(:file_path) { "with_leading_comment.strings" }

    it "recognises an ios strings file" do
      expect {
        post :import, {platform: :ios, file: file_upload, format: "json", id: selected_project.slug}
      }.to change(MasterText, :count).by(3)
    end

    it "accepts a strings file upload" do
      expect {
        post :import, {platform: :ios, file: file_upload, format: "json", id: selected_project.slug}
      }.to change(MasterText, :count).by(3)
    end

    it "creates the expected master texts" do
      post :import, {platform: :ios, file: file_upload, format: "json", id: selected_project.slug}
      masters = MasterText.all
      pairs = masters.map { |mt| [mt.key, mt.text] }
      expect(pairs).to include(["Adding", "Adding..."])
      expect(pairs).to include(["Almost done", "Almost done..."])
      expect(pairs).to include(["Done", "Done!"])
    end
  end

  describe "Android" do
    let(:file_path) { "simple_strings.xml" }

    context("mocked") do
      before do
        localizations = build_list(:localization, 3)
        expect(Android::ResourceFile).to receive(:parse).and_return(localizations)
        localizations.define_singleton_method(:close){}
        expect(localizations).to receive(:close)
        expect(Localization).to receive(:create_master_texts).with(localizations, selected_project)
      end

      it "recognises a android xml" do
        post :import, {file: file_upload, format: "json", id: selected_project.slug}
      end

      it "accepts a android xml upload" do
        post :import, {platform: :android, file: file_upload, format: "json", id: selected_project.slug}
      end
    end

    context("full-stack") do
      it "creates the expected master texts" do
        post :import, {platform: :android, file: file_upload, format: "json", id: selected_project.slug}
        masters = MasterText.all
        expect(masters.map { |mt| [mt.key, mt.text] }).to eq([["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]])
      end
    end
  end

  describe "Yaml" do
    let(:file_path) { "simple_strings.yml" }

    context("mocked") do
      before do
        localizations = build_list(:localization, 3)
        expect(RailsYamlFormat::YamlFile).to receive(:parse).and_return(localizations)
        localizations.define_singleton_method(:close){}
        expect(localizations).to receive(:close)
        expect(Localization).to receive(:create_master_texts).with(localizations, selected_project)
      end

      it "recognises a yaml file" do
        post :import, {file: file_upload, format: "json", id: selected_project.slug}
      end

      it "accepts a yaml file upload" do
        post :import, {file: file_upload, format: "json", id: selected_project.slug}
      end
    end

    context("full-stack") do
      it "creates the expected master texts" do
        post :import, {file: file_upload, format: "json", id: selected_project.slug}
        masters = MasterText.all
        expect(masters.map { |mt| [mt.key, mt.text] }).to eq([["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]])
      end
    end

    context "with multiple projects" do
      let(:projects) {build_stubbed_list(:project, 2)}
      let(:selected_project) {projects.last}

      it "can select the last project" do
        localizations = build_list(:localization, 3)
        expect(RailsYamlFormat::YamlFile).to receive(:parse).and_return(localizations)
        localizations.define_singleton_method(:close){}
        expect(localizations).to receive(:close)
        expect(Localization).to receive(:create_master_texts).with(localizations, selected_project)
        expect(Project).to receive(:find_by_slug).with(selected_project.slug).and_return(selected_project)
        post :import, {platform: :yaml, file: file_upload, format: "json", id: selected_project.slug}
      end
    end
  end
end
