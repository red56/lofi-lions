require 'rails_helper'

describe 'Project Pages', :type => :feature do
  let(:project) { create(:project, name: "steve") }

  before do
    stubbed_login_as_admin_user
  end

  it "shows project" do
    visit project_path(project)
    expect(page).to have_content(project.name)
  end

end
