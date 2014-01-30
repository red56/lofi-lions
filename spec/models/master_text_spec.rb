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
  end
end
