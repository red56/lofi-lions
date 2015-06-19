require 'spec_helper'
require 'android'
require 'ios'

describe ImportController, :type => :controller do
  let(:file_upload) { fixture_file_upload(file_path, 'application/octet-stream') }

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
        post :auto, {file: file_upload, format: 'json'}
      }.to change(MasterText, :count).by(3)
    end

    it "accepts a strings file upload" do
      expect {
        post :ios, {file: file_upload, format: 'json'}
      }.to change(MasterText, :count).by(3)
    end

    it "creates the expected master texts" do
      post :ios, {file: file_upload, format: 'json'}
      masters = MasterText.all
      pairs = masters.map { |mt| [mt.key, mt.text] }
      expect(pairs).to include(["Adding", "Adding..."])
      expect(pairs).to include(["Almost done", "Almost done..."])
      expect(pairs).to include(["Done", "Done!"])
    end

    it "redirects to the master text view" do
      post :ios, {file: file_upload, format: 'html'}
      expect(response).to redirect_to(master_texts_path)
    end
  end

  describe "Android" do
    let(:file_path) { "simple_strings.xml" }

    context("mocked") do
      before do
        localizations = build_list(:localization, 3)
        expect(Android::ResourceFile).to receive(:parse).and_return(localizations)
        expect(localizations).to receive(:close)
        expect(Localization).to receive(:create_master_texts).with(localizations)
      end

      it "recognises a android xml" do
        post :auto, {file: file_upload, format: 'json'}
      end

      it "accepts a android xml upload" do
        post :android, {file: file_upload, format: 'json'}
      end

      it "redirects to the master text view" do
        post :android, {file: file_upload, format: 'html'}
      end
    end

    context("full-stack") do
      it "creates the expected master texts" do
        post :android, {file: file_upload, format: 'json'}
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
        expect(localizations).to receive(:close)
        expect(Localization).to receive(:create_master_texts).with(localizations)
      end

      it "recognises a yaml file" do
        post :auto, {file: file_upload, format: 'json'}
      end

      it "accepts a yaml file upload" do
        post :yaml, {file: file_upload, format: 'json'}
      end

      it "redirects to the master text view" do
        post :yaml, {file: file_upload, format: 'html'}
      end
    end

    context("full-stack") do
      it "creates the expected master texts" do
        post :yaml, {file: file_upload, format: 'json'}
        masters = MasterText.all
        expect(masters.map { |mt| [mt.key, mt.text] }).to eq([["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]])
      end
    end
  end
end
