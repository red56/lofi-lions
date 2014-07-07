require 'spec_helper'

describe View, :type => :model do
  let(:view) { create :view }
  let(:master_texts){ create_list(:master_text, 3)}
  def add_reversed
    master_texts.each_with_index do |master_text, i|
      view.key_placements.create(master_text_id: master_text.id, position: 3-i)
    end
  end
    describe "#keys" do
    it "works empty" do
      expect(view.keys).to eq('')
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


end