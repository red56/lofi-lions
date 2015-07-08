require 'rails_helper'

describe "Project Language Views" do

  context "with outstanding tasks" do
    let(:project_language) { build_stubbed(:project_language, need_entry_count: 5, need_review_count: 6) }

    it "has entry count" do
      render partial: 'project_languages/list_group_item', locals: {project_language: project_language,
              label: project_language}
      within ".entry" do
        expect(rendered).to have_content(project_language.need_entry_count)
      end
    end

    it "has review count" do
      render partial: 'project_languages/list_group_item', locals: {project_language: project_language,
              label: project_language}
      within ".review" do
        expect(rendered).to have_content(project_language.need_review_count)
      end
    end
  end

  context "wihout outstanding tasks" do
    let(:project_language) { build_stubbed(:project_language, need_entry_count: 0, need_review_count: 0) }

    it "has entry count" do
      render partial: 'project_languages/list_group_item', locals: {project_language: project_language,
              label: project_language}
      within ".entry" do
        expect(rendered).to have_content("No outstanding entries")
      end
    end

    it "has review count" do
      render partial: 'project_languages/list_group_item', locals: {project_language: project_language,
              label: project_language}
      within ".review" do
        expect(rendered).to have_content("No outstanding reviews")
      end
    end
  end
end