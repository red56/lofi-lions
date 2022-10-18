require "rails_helper"

describe "View (non-localized) pages", type: :feature do
  before { login }
  let(:login) { stubbed_login_as_developer }
  let!(:project) { create :project }

  context "when not logged in" do
    let(:login) { nil }
    it "redirects to login page" do
      visit project_views_path(project)
      expect(current_path).to eq(new_user_session_path)
    end
  end

  specify "when creating can write in keys to use" do
    master_texts = create_list(:master_text, 5, project: project)
    visit new_project_view_path(project)
    expect(page).to have_css("form.view")
    fill_in :view_name, with: "flongy"
    some_keys = [master_texts[3].key, master_texts[4].key, master_texts[2].key].join("\n")
    fill_in :view_keys, with: some_keys
    click_on "Create View"
    expect(page).not_to have_css("form.view")
    expect(View.last.reload.master_texts.to_a).to eq([master_texts[3], master_texts[4], master_texts[2]])
  end

  let(:view) { create :view, project: project }
  it "shows ok" do
    visit view_path(view)
  end
  it "edits ok" do
    visit edit_view_path(view)
  end

  context "with multiple projects" do
    let!(:other_project) { create(:project) }
    let!(:other_projects_view) { create(:view, project: other_project, name: "Ella") }
    let!(:our_view) { create(:view, project: project, name: "Nick") }

    it "doesn't show other projects views" do
      visit project_views_path(project)
      expect(page).not_to have_content(other_projects_view.name)
      visit project_views_path(other_project)
      expect(page).not_to have_content(our_view.name)
    end
  end
end
