require 'rails_helper'

describe 'One by One Edit Page', :type => :feature do
  let!(:project_language) { create(:project_language) }
  let!(:empty_localized_text) { create(:localized_text, project_language: project_language, needs_entry: true) }

  before { login }
  let(:login) { stubbed_login_as_user }

  it "links from project language text list" do
    visit entry_project_language_texts_path(project_language)
    expect(page).to have_content("Edit")
    expect(page).to have_link_to(edit_localized_text_path(empty_localized_text.id))
  end
end
