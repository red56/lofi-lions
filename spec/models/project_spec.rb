# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  describe "validation" do
    let(:project) { build :project }

    it "slugifies" do
      project.slug = nil
      expect { project.valid? }.to change { project.slug }.from(nil)
    end
  end

  describe "find_and_replace" do
    let(:project) { create(:project) }
    let!(:master_text) { create(:master_text, project: project, text: "One two three") }
    let!(:localized_text) { create(:localized_text, master_text: master_text, text: "Un deux trois two") }

    it "fixes master_texts" do
      expect {
        project.find_and_replace("two" => "2")
      }.to change { master_text.reload.text }
        .from("One two three")
        .to("One 2 three")
    end

    it "fixes master_texts with multiple" do
      expect {
        project.find_and_replace("two" => "2", "three" => "3")
      }.to change { master_text.reload.text }
        .from("One two three")
        .to("One 2 3")
    end

    it "fixes localized_texts" do
      expect {
        project.find_and_replace("two" => "2", "three" => "3")
      }.to change { localized_text.reload.text }
        .from("Un deux trois two")
        .to("Un deux trois 2")
    end
  end
end
