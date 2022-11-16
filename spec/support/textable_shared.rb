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
  end
end
