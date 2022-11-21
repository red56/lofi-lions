# frozen_string_literal: true

require "rails_helper"

describe MasterTextAsXx do
  let(:master_text) { create(:master_text, other: "Once upon 1 time") }
  let(:master_text_as_xx) { described_class.new(master_text) }

  it "replaces other" do
    expect(master_text_as_xx.other).to eq("Xxxx xxxx 1 xxxx")
  end

  it "replaces other_export" do
    expect(master_text_as_xx.other_export).to eq("Xxxx xxxx 1 xxxx")
  end

  context "when pluralizable" do
    let(:master_text) { create(:master_text, one: "Once upon 1 time", other: "Once upon 4 times") }

    it "replaces one" do
      expect(master_text_as_xx.one).to eq("Xxxx xxxx 1 xxxx")
    end

    it "replaces two" do
      expect(master_text_as_xx.two).to eq("Xxxx xxxx 4 xxxxx")
    end
  end
end
