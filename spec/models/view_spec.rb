# frozen_string_literal: true

require "rails_helper"

describe View, type: :model do
  let(:view) { create :view }
  let(:master_texts) { create_list(:master_text, 3) }

  def add_reversed
    master_texts.each_with_index do |master_text, i|
      view.key_placements.create!(master_text_id: master_text.id, position: 3 - i)
    end
  end

  describe "#keys" do
    it "works empty" do
      expect(view.keys).to eq("")
    end

    it "works full" do
      add_reversed
      expect(view.keys).to eq([master_texts[2].key, master_texts[1].key,
                               master_texts[0].key].join("\n"))
    end
  end

  describe "#keys=" do
    it "works empty" do
      add_reversed
      view.keys = ""
      expect(view.reload.master_texts).to eq([])
    end

    it "works full" do
      view.keys = [master_texts[2].key, master_texts[1].key, master_texts[0].key].join("\n")
      expect(view.reload.master_texts).to eq([master_texts[2], master_texts[1], master_texts[0]])
    end
  end

  describe "validations" do
    let(:view) { build(:view) }

    specify "factory produces valid" do
      expect(view).to be_valid
    end

    it "requires a project" do
      view.project_id = nil
      expect(view).not_to be_valid
    end
  end

  context "#name" do
    let(:existing) { create :view, project: create(:project) }

    it "must be unique" do
      expect(View.new(name: existing.name, project: existing.project)).not_to be_valid
    end

    it "only unique in same project" do
      expect(View.new(name: existing.name, project: create(:project))).to be_valid
    end
  end
end
