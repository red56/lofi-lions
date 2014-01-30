require 'spec_helper'

describe Language do
  describe "validations" do
    let(:language) { create(:language) }
    it "basically works" do
      language.should be_valid
    end
    it "requires name" do
      language.name = nil
      language.should_not be_valid
    end
    it "requires name" do
      language.name = ''
      language.should_not be_valid
    end
    it "requires code" do
      language.code = nil
      language.should_not be_valid
    end
    it "requires code" do
      language.code = ''
      language.should_not be_valid
    end
  end
end
