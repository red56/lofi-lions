# frozen_string_literal: true

require "rails_helper"

describe Api::ProjectsController, type: :controller do
  let(:file_upload) { fixture_file_upload(file_path, "application/octet-stream") }
  let(:selected_project) { create(:project) }

  shared_context "full-stack" do
    let(:language) { create :language, code: "zh" }
    let(:project_language) { create :project_language, language: language, project: selected_project }
    before do
      ["Adding", "Almost done", "Done"].each do |key|
        create :master_text, key: key, project_id: selected_project.id
      end
    end

    def request
      post :import, params: { platform: platform, file: file_upload, code: project_language.language.code, format: "json", id: selected_project.slug }
    end
  end
  describe "with language specified" do
    let(:localizations) { Localization::CollectionWrappingArray.new(build_list(:localization, 3)) }
    let(:chinese) { build_stubbed(:language, :type_0_chinese, code: "zh", name: "Chinese") }

    context "without auth token" do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it "should fail with 401?"
    end

    context "with invalid auth token" do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it "should fail with 401?"
    end

    describe "ios" do
      let(:file_path) { "with_no_comment.strings" }

      context("mocked") do
        it "accepts a android xml upload" do
          expect(Language).to receive(:find_by_code).with("zh").and_return(chinese)
          expect(IOS::StringsFile).to receive(:parse).and_return(localizations)
          localizations.define_singleton_method(:close) {}
          expect(localizations).to receive(:close)
          expect(Localization).to receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection), selected_project.id)

          post :import, params: { platform: :ios, file: file_upload, code: "zh", format: "json", id: selected_project.slug }
        end

        it "should stop if it receives unknown code" do
          expect(Language).to receive(:find_by_code).with("zh").and_return(nil)
          expect(Localization).not_to receive(:create_localized_texts)
          post :import, params: { platform: :ios, file: file_upload, code: "zh", format: "json", id: selected_project.slug }
        end
      end

      context("full-stack") do
        include_context "full-stack"
        let(:platform) { :ios }

        it "creates the expected localised texts" do
          request
          localized = LocalizedText.all.map { |mt| [mt.key, mt.other] }
          expect(localized).to include(["Adding", "Adding..."])
          expect(localized).to include(["Almost done", "Almost done..."])
          expect(localized).to include(["Done", "Done!"])
        end
      end
    end

    describe "Android" do
      let(:file_path) { "simple_strings.xml" }

      context("mocked") do
        it "accepts a android xml upload" do
          expect(Language).to receive(:find_by_code).with("zh").and_return(chinese)
          expect(Android::ResourceFile).to receive(:parse).and_return(localizations)
          localizations.define_singleton_method(:close) {}
          expect(localizations).to receive(:close)
          expect(Localization).to receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection), selected_project.id)
          post :import, params: { platform: :android, file: file_upload, code: "zh", format: "json", id: selected_project.slug }
        end

        it "should stop if it receives unknown code" do
          expect(Language).to receive(:find_by_code).with("zh").and_return(nil)
          expect(Localization).not_to receive(:create_localized_texts)
          post :import, params: { platform: :android, file: file_upload, code: "zh", format: "json", id: selected_project.slug }
        end
      end

      context("full-stack") do
        include_context "full-stack"
        let(:platform) { :android }

        it "creates the expected master texts" do
          request
          localized = LocalizedText.all.map { |mt| [mt.key, mt.other] }
          expect(localized).to include(["Adding", "Adding..."])
          expect(localized).to include(["Almost done", "Almost done..."])
          expect(localized).to include(["Done", "Done!"])
        end
      end
    end

    describe "Yaml" do
      let(:file_path) { "simple_strings.yml" }

      context("mocked") do
        it "accepts a yaml upload" do
          expect(Language).to receive(:find_by_code).with("zh").and_return(chinese)
          expect(RailsYamlFormat::YamlFile).to receive(:parse).and_return(localizations)
          localizations.define_singleton_method(:close) {}
          expect(localizations).to receive(:close)
          expect(Localization).to receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection), selected_project.id)
          post :import, params: { platform: :yaml, file: file_upload, code: "zh", format: "json", id: selected_project.slug }
        end

        it "should stop if it receives unknown code" do
          expect(Language).to receive(:find_by_code).with("zh").and_return(nil)
          expect(Localization).not_to receive(:create_localized_texts)
          post :import, params: { platform: :yaml, file: file_upload, code: "zh", format: "json", id: selected_project.slug }
        end
      end

      context("full-stack") do
        include_context "full-stack"
        let(:platform) { :yaml }

        it "creates the expected master texts" do
          request
          localized = LocalizedText.all.map { |mt| [mt.key, mt.other] }
          expect(localized).to include(["Adding", "Adding..."])
          expect(localized).to include(["Almost done", "Almost done..."])
          expect(localized).to include(["Done", "Done!"])
        end
      end

      context "with multiple projects" do
        let(:projects) { build_stubbed_list(:project, 2) }
        let(:selected_project) { projects.last }

        it "adds texts to the selected projects" do
          expect(RailsYamlFormat::YamlFile).to receive(:parse).and_return(localizations)
          localizations.define_singleton_method(:close) {}
          expect(localizations).to receive(:close)
          expect(Project).to receive(:find_by_slug).with(selected_project.slug).and_return(selected_project)

          expect(Language).to receive(:find_by_code).with("zh").and_return(chinese)
          expect(Localization).to receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection), selected_project.id)
          post :import, params: { platform: :yaml, file: file_upload, code: "zh", format: "json", id: selected_project.slug }
        end
      end
    end
  end
end
