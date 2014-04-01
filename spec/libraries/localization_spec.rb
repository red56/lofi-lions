require 'localization'
require "spec_helper"

describe Localization do

  describe "create_master_texts" do
    it 'works with non pluralized' do
      expect{
      Localization.create_master_texts([Localization.new("somekey", "something new in sandwiches")])
      }.to change{MasterText.count}.by(1)
    end
  end
  describe "create_master_texts" do
    it 'works with non pluralized' do
      expect{
        Localization.create_master_texts([Localization.new("sandy", one: "one sandwich", other: "%d sandwiches")])
      }.to change{MasterText.count}.by(1)
      MasterText.last.pluralizable.should be_true
      MasterText.last.one.should == "one sandwich"
      MasterText.last.other.should == "%d sandwiches"
    end
  end
end