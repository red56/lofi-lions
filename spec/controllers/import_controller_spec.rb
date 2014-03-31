require 'spec_helper'

describe ImportController do
  let(:valid_session) { {} }

  pending "needs test" do
    context "without auth token" do
      it "should fail with 401?"
    end
    context "with invalid auth token" do
      it "should fail with 401?"
    end
  end

  describe "iOS" do
    let(:strings_file_path) { "with_leading_comment.strings" }
    let(:strings_file_upload) { fixture_file_upload(strings_file_path, 'application/octet-stream') }

    it "recognises an ios strings file" do
      expect {
        post :auto, {file: strings_file_upload, format: 'json'}, valid_session
      }.to change(MasterText, :count).by(3)
    end

    it "accepts a strings file upload" do
      expect {
        post :ios, {file: strings_file_upload, format: 'json'}, valid_session
      }.to change(MasterText, :count).by(3)
    end

    it "creates the expected master texts" do
      post :ios, {file: strings_file_upload, format: 'json'}, valid_session
      masters = MasterText.all
      masters.map { |mt| [mt.key, mt.text] }.should == [["Adding", "Adding..."], ["Almost done", "Almost done..."], ["Done", "Done!"]]
    end

    it "redirects to the master text view" do
      post :ios, {file: strings_file_upload, format: 'html'}, valid_session
      response.should redirect_to(master_texts_path)
    end
  end
end
