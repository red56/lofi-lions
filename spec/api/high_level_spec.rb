# frozen_string_literal: true

require "rails_helper"

describe "High-level API spec", type: :request do
  let(:file_upload) { fixture_file_upload("simple_strings.yml", "application/octet-stream") }
  let!(:project) { create(:project, name: "Proj") }
  let(:language) { create(:language) }
  let!(:project_language) { create(:project_language, project: project, language: language) }

  it "can import master_texts" do
    expect {
      post "/api/projects/#{project.slug}/import/yaml", params: { file: file_upload }
    }.to change { project.reload.master_texts.count }
  end

  context "with some master texts" do
    before {
      create(:master_text, project: project, key: "Adding", other: "there")
    }

    it "can import localizations" do
      expect {
        post "/api/projects/#{project.slug}/languages/#{language.code}/import/yaml", params: { file: file_upload }
      }.to change { project.reload.localized_texts.count }
    end
  end

  context "with some localized texts" do
    before {
      mt = create(:master_text, project: project, key: "key", other: "there")
      mt.localized_texts.create!(project_language: project_language, text: "voila")
    }

    it "can export" do
      get "/api/projects/#{project.slug}/export/yaml/#{language.code}", params: {}
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("voila")
    end
  end
end
