# frozen_string_literal: true

require "rails_helper"

describe User, type: :model do
  describe "destroy" do
    let!(:user) { create :user }

    it "works" do
      expect { user.destroy }.to change { User.count }.by(-1)
    end

    context "with a project language" do
      let!(:project_language) { create(:project_language) }

      before { user.project_languages << project_language }

      it "works" do
        expect { user.destroy }.to change { User.count }.by(-1)
      end

      it "doesn't destroy project language" do
        expect { user.destroy }.not_to change { ProjectLanguage.count }
      end

      it "doesn't leave anything behind" do
        expect { user.destroy }.to change { ProjectLanguage.joins(:users).count }.by(-1)
      end
    end
  end
end
