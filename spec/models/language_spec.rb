require 'spec_helper'

describe Language do
  describe "validations" do
    let(:language) { build(:language) }
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

  describe "plurals" do
    let(:language) { build(:language) }
    it "should be a hash" do
      language.plurals.should be_a(Hash)
    end
    context "with some specific labels" do
      let(:language) { build(:language, :type_0_chinese) }
      it "should be a hash" do
        language.plurals.should == {other: 'everything'}
      end
    end
    context "with some specific labels" do
      let(:language) { build(:language, :type_1_english) }
      it "should be a hash" do
        language.plurals.should == {one: 'is 1', other: 'everything else'}
      end
    end
  end
end
