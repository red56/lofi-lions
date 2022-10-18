require "rails_helper"

RSpec.describe Project, type: :model do
  describe "validation" do
    let(:project) { build :project }

    it "slugifies" do
      project.slug = nil
      expect { project.valid? }.to change { project.slug }.from(nil)
    end
  end
end
