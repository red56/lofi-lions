require 'localization'
require "spec_helper"

describe Localization do

  describe "create_master_texts" do
    it 'works with non pluralized' do
      expect {
        Localization.create_master_texts([Localization.new("somekey", "something new in sandwiches")])
      }.to change { MasterText.count }.by(1)
    end
    it 'works with non pluralized' do
      expect {
        Localization.create_master_texts([Localization.new("somekey", one: "one sandwich", other: "%d sandwiches")])
      }.to change { MasterText.count }.by(1)
      MasterText.last.pluralizable.should be_truthy
      MasterText.last.one.should == "one sandwich"
      MasterText.last.other.should == "%d sandwiches"
    end
  end

  describe "create_localized_texts" do
    let(:language) { create :language }
    context "with master key" do
      before { master_text }
      let(:master_text) { create :master_text, key: "somekey" }
      it 'creates' do
        expect {
          Localization.create_localized_texts(language, [Localization.new("somekey", "something new in sandwiches")])
        }.to change { LocalizedText.count }.by(1)
        LocalizedText.last.language.should == language
      end
      it "returns no errors" do
        result = Localization.create_localized_texts(language, [Localization.new("somekey",
            "something new in sandwiches")])
        result.should be_empty
      end
      it 'creates pluralized forms' do
        expect {
          Localization.create_localized_texts(language, [Localization.new("somekey", one: "one sandwich",
              two: "two sandwiches", other: "%d sandwiches")])
        }.to change { LocalizedText.count }.by(1)
        localized_text = LocalizedText.last
        localized_text.one.should == "one sandwich"
        localized_text.two.should == "two sandwiches"
        localized_text.other.should == "%d sandwiches"
      end
      context "when already exists" do
        before { localized_text }
        let(:localized_text) { create :localized_text, language: language, master_text: master_text,
            other: "some value" }
        it "updates" do
          expect {
            Localization.create_localized_texts(language, [Localization.new("somekey", one: "one sandwich",
                two: "two sandwiches", other: "%d sandwiches")])
          }.not_to change { LocalizedText.count }
          localized_text.reload
          localized_text.one.should == "one sandwich"
          localized_text.two.should == "two sandwiches"
          localized_text.other.should == "%d sandwiches"
        end
      end
    end
    context "without master text" do
      it 'returns errors' do
        expect {
          result = Localization.create_localized_texts(language, [Localization.new("somekey",
              "something new in sandwiches")])
          result.should_not be_empty
        }.not_to change { LocalizedText.count }

      end
    end
  end
end