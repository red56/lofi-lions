require 'spec_helper'
require 'android/resource_file'

describe LanguagesImportController do
  let(:file_upload) { fixture_file_upload(file_path, 'application/octet-stream') }

  context "without auth token" do
    it "should fail with 401?"
  end
  context "with invalid auth token" do
    it "should fail with 401?"
  end

  let(:chinese) { build_stubbed(:language, :type_0_chinese, code: 'zh', name: "Chinese") }
  let(:localizations) { Localization::CollectionWrappingArray.new(build_list(:localization, 3)) }

  describe "ios" do
    let(:file_path) { "with_no_comment.strings" }

    context("mocked") do
      before do
        localizations = build_list(:localization, 3)
      end

      it "accepts a android xml upload" do
        Language.should_receive(:find_by_code).with('zh').and_return(chinese)
        IOS::StringsFile.should_receive(:parse).and_return(localizations)
        localizations.should_receive(:close)
        Localization.should_receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection))
        post :ios, {file: file_upload, id: 'zh', format: 'json'}
      end
      it "should stop if it receives unknown code" do
        Language.should_receive(:find_by_code).with('zh').and_return(nil)
        Localization.should_not_receive(:create_localized_texts)
        post :ios, {file: file_upload, id: 'zh', format: 'json'}
      end
    end

    context("full-stack") do
      before do
        create :language, code: 'zh'
        ["Adding", "Almost done", "Done"].each do |key|
          create :master_text, key: key
        end
      end

      it "creates the expected localised texts" do
        post :ios, {file: file_upload, id: 'zh', format: 'json'}
        localized = LocalizedText.all.map { |mt| [mt.key, mt.other] }
        localized.should include(["Adding", "Adding..."])
        localized.should include(["Almost done", "Almost done..."])
        localized.should include(["Done", "Done!"])
      end
    end
  end

  describe "Android" do
    let(:file_path) { "simple_strings.xml" }

    context("mocked") do
      before do
        localizations = build_list(:localization, 3)
      end

      it "accepts a android xml upload" do
        Language.should_receive(:find_by_code).with('zh').and_return(chinese)
        Android::ResourceFile.should_receive(:parse).and_return(localizations)
        localizations.should_receive(:close)
        Localization.should_receive(:create_localized_texts).with(chinese, a_kind_of(Localization::Collection))
        post :android, {file: file_upload, id: 'zh', format: 'json'}
      end
      it "should stop if it receives unknown code" do
        Language.should_receive(:find_by_code).with('zh').and_return(nil)
        Localization.should_not_receive(:create_localized_texts)
        post :android, {file: file_upload, id: 'zh', format: 'json'}
      end
    end

    context("full-stack") do
      before {
        create :language, code: 'zh'
        ["Adding", "Almost done", "Done"].each do |key|
          create :master_text, key: key
        end
      }

      it "creates the expected master texts" do
        post :android, {file: file_upload, id: 'zh', format: 'json'}
        localized = LocalizedText.all.map { |mt| [mt.key, mt.other] }
        localized.should include(["Adding", "Adding..."])
        localized.should include(["Almost done", "Almost done..."])
        localized.should include(["Done", "Done!"])
      end
    end
  end
end


