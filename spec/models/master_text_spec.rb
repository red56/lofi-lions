require 'rails_helper'

describe MasterText, :type => :model do
  describe "validations" do
    let(:master_text) { build(:master_text) }
    it "basically works" do
      expect(master_text).to be_valid
    end
    it "requires key" do
      master_text.key = nil
      expect(master_text).not_to be_valid
    end
    it "requires key" do
      master_text.key = ''
      expect(master_text).not_to be_valid
    end
    it "requires unique key" do
      master_text.save!
      new_master_text = MasterText.new(key: master_text.key)
      expect(new_master_text).not_to be_valid
    end
    it "requires text" do
      master_text.text = nil
      expect(master_text).not_to be_valid
    end
    it "requires text" do
      master_text.text = ''
      expect(master_text).not_to be_valid
    end
    context "pluralizable" do
      let(:master_text) { build(:master_text, pluralizable: true) }
      it "basically works" do
        expect(master_text).to be_valid
      end
      it "requires key" do
        master_text.key = nil
        expect(master_text).not_to be_valid
      end
      it "requires key" do
        master_text.key = ''
        expect(master_text).not_to be_valid
      end
      it "requires unique key" do
        master_text.save!
        new_master_text = MasterText.new(key: master_text.key)
        expect(new_master_text).not_to be_valid
      end
      it "requires other" do
        master_text.other = ''
        expect(master_text).not_to be_valid
      end
    end
  end

  context "pluralizable" do
    let(:master_text) { build(:master_text, pluralizable: true) }
    it "can't return text" do
      expect {
        master_text.text
      }.to raise_error
    end

  end

  describe "text_changed?" do
    shared_examples_for "shared_text_changed" do
      it "is false when key changing" do
        master_text.key = "flong"
        expect(master_text.text_changed?).to be_falsey
      end
      it "is false when nothing changing" do
        expect(master_text.text_changed?).to be_falsey
      end
      it "is true when pluralizable" do
        master_text.pluralizable = !master_text.pluralizable
        expect(master_text.text_changed?).to be_truthy
      end
    end
    context "when unpluralized" do
      let(:master_text) { create(:master_text, pluralizable: false) }
      it "is true when text changing" do
        master_text.text = "flong"
        expect(master_text.text_changed?).to be_truthy
      end
      include_examples "shared_text_changed"
    end
    context "when pluralized" do
      let(:master_text) { create(:master_text, pluralizable: true) }
      it "is true when one changing" do
        master_text.one = "flong"
        expect(master_text.text_changed?).to be_truthy
      end
      it "is true when other changing" do
        master_text.other = "flong"
        expect(master_text.text_changed?).to be_truthy
      end
      include_examples "shared_text_changed"
    end
  end
end
