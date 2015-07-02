require "rails_helper"

describe "High-level API spec", type: :request do
  let(:file_upload) { fixture_file_upload(Rails.root.join("spec/fixtures/simple_strings.yml"), 'application/octet-stream') }
  let!(:project) { create(:project) }
  let(:language) { create(:language) }

  it "can import master_texts" do
    expect {
      post "/projects/#{project.id}/import/yaml", file: file_upload
    }.to change { project.reload.master_texts.count }
  end

  context "with some master texts" do
    before {
      create(:master_text, project: project, key: 'Adding', other: 'there')
    }

    it "can import localizations" do
      expect {
        post "/projects/#{project.id}/languages/#{language.code}/import/yaml", file: file_upload
      }.to change { project.reload.localized_texts.count }
    end
  end

  context "with some localized texts" do
    before {
      mt = create(:master_text, project: project, key: 'key', other: 'there')
      mt.localized_texts.create!(language: language, text: 'voila')
    }
    it "can export" do
      get "/projects/#{project.id}/export/yaml/#{language.code}"
      expect(response.status).to eq(200)
      expect(response.body).to include("voila")
    end
  end

end