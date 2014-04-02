require 'spec_helper'
require 'android_resource_file'

describe ImportController do
  let(:file_upload) { fixture_file_upload(file_path, 'application/octet-stream') }

  context "without auth token" do
    it "should fail with 401?"
  end
  context "with invalid auth token" do
    it "should fail with 401?"
  end

  describe "iOS" do
    let(:file_path) { "with_leading_comment.strings" }
    let(:file_upload) { fixture_file_upload(file_path, 'application/octet-stream') }

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
      pairs.should include(["Adding", "Adding..."])
      pairs.should include(["Almost done", "Almost done..."])
      pairs.should include(["Done", "Done!"])
    end

    it "redirects to the master text view" do
      post :ios, {file: file_upload, format: 'html'}
      response.should redirect_to(master_texts_path)
    end
  end

  describe "Android" do
    let(:file_path) { "simple_strings.xml" }

    context("mocked") do
      before do
        localizations = build_list(:localization, 3)
        AndroidResourceFile.should_receive(:parse).and_return(localizations)
        Localization.should_receive(:create_master_texts).with(localizations)
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
        masters.map { |mt| [mt.key, mt.text] }.should == [["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]]
      end
    end
  end

end
