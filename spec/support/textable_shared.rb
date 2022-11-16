# frozen_string_literal: true

require "rails_helper"

RSpec.configure do
  shared_examples "behaves as textable" do
    describe "#non_blank_lines" do
      it "splits one" do
        expect(build(factory_name, text: "one").non_blank_lines).to eq(["one"])
      end

      it "strips one" do
        expect(build(factory_name, text: "\n\n\t one\n\n\t ").non_blank_lines).to eq(["one"])
      end

      it "splits three" do
        expect(build(factory_name, text: "one\ntwo\nthree\n").non_blank_lines).to eq(["one", "two", "three"])
      end
    end

    describe "#strip_bullets" do
      it "has a noop" do
        textable = build(factory_name, text: "one")
        expect { textable.strip_bullets }.not_to change { textable.text }
      end

      it "strips one" do
        textable = build(factory_name, text: "* one")
        expect { textable.strip_bullets }.to change { textable.text }.to "one"
      end

      it "strips one with noops" do
        textable = build(factory_name, text: "one\n\n* two\n\nthree")
        expect { textable.strip_bullets }.to change { textable.text }.to "one\n\ntwo\n\nthree"
      end

      it "strips three" do
        textable = build(factory_name, text: "* one\n* two\n* three ")
        expect { textable.strip_bullets }.to change { textable.text }.to "one\n\ntwo\n\nthree"
      end

      it "strips one with spaces" do
        textable = build(factory_name, text: "\n\n* one\n\n\t ")
        expect { textable.strip_bullets }.to change { textable.text }.to "one"
      end

      it "strips with windows" do
        textable = build(factory_name, text: "\r\n* one\r\n* two\r\n* three\r\n")
        expect { textable.strip_bullets }.to change { textable.text }.to "one\n\ntwo\n\nthree"
      end
    end
  end
end
