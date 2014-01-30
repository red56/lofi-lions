require 'spec_helper'

describe LocalizedText do
  describe "validations" do
    let(:localized_text) { build(:localized_text) }
    it "basically works" do
      localized_text.should be_valid
    end
    it "requires master_text_id" do
      localized_text.master_text_id = nil
      localized_text.should_not be_valid
    end
    it "requires language id" do
      localized_text.language_id = nil
      localized_text.should_not be_valid
    end
  end
end
