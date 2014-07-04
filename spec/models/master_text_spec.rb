require 'spec_helper'

describe MasterText do
  describe "validations" do
    let(:master_text) { build(:master_text) }
    it "basically works" do
      master_text.should be_valid
    end
    it "requires key" do
      master_text.key = nil
      master_text.should_not be_valid
    end
    it "requires key" do
      master_text.key = ''
      master_text.should_not be_valid
    end
    it "requires unique key" do
      master_text.save!
      new_master_text = MasterText.new(key: master_text.key)
      new_master_text.should_not be_valid
    end
    it "requires text" do
      master_text.text = nil
      master_text.should_not be_valid
    end
    it "requires text" do
      master_text.text = ''
      master_text.should_not be_valid
    end
    context "pluralizable" do
      let(:master_text) { build(:master_text, pluralizable: true) }
      it "basically works" do
        master_text.should be_valid
      end
      it "requires key" do
        master_text.key = nil
        master_text.should_not be_valid
      end
      it "requires key" do
        master_text.key = ''
        master_text.should_not be_valid
      end
      it "requires unique key" do
        master_text.save!
        new_master_text = MasterText.new(key: master_text.key)
        new_master_text.should_not be_valid
      end
      it "requires other" do
        master_text.other = ''
        master_text.should_not be_valid
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
        master_text.text_changed?.should be_falsey
      end
      it "is false when nothing changing" do
        master_text.text_changed?.should be_falsey
      end
      it "is true when pluralizable" do
        master_text.pluralizable = !master_text.pluralizable
        master_text.text_changed?.should be_truthy
      end
    end
    context "when unpluralized" do
      let(:master_text) { create(:master_text, pluralizable: false) }
      it "is true when text changing" do
        master_text.text = "flong"
        master_text.text_changed?.should be_truthy
      end
      include_examples "shared_text_changed"
    end
    context "when pluralized" do
      let(:master_text) { create(:master_text, pluralizable: true) }
      it "is true when one changing" do
        master_text.one = "flong"
        master_text.text_changed?.should be_truthy
      end
      it "is true when other changing" do
        master_text.other = "flong"
        master_text.text_changed?.should be_truthy
      end
      include_examples "shared_text_changed"
    end
  end
end
