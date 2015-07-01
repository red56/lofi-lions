require 'spec_helper'

shared_examples_for "a BaseExporter" do

  specify "should find correct class" do
    klass = BaseExporter.class_for(platform)
    expect(klass).not_to be_nil
    expect(klass).not_to eq BaseExporter
    expect(klass).to be < BaseExporter

  end
  describe "instance" do
    subject { BaseExporter.class_for(platform).new(language) }

    it "should respond to path" do
      expect(subject.path).to be_a String
    end
    it "should respond to content_type" do
      expect(subject.content_type).to be_a String
    end
    it "should respond to body_for(texts)" do
      expect(subject.body_for(localized_texts)).to be_a String
    end
    it "should respond to body" do
      expect(subject.body).to be_a String
    end
  end

end

describe "Exporters" do
  let(:language) { build_stubbed(:language, code: 'la') }
  let(:localized_texts) { build_stubbed_list(:stubbed_localized_text, 3, language: language) }
  before {
    allow(language).to receive(:localized_texts_with_fallback).and_return(localized_texts)
  }
  describe Android::Exporter do
    it_behaves_like "a BaseExporter" do
      let(:platform) { :android }
    end
  end

  describe IOS::Exporter do
    it_behaves_like "a BaseExporter" do
      let(:platform) { :ios }
    end
  end

  describe RailsYamlFormat::Exporter do
    it_behaves_like "a BaseExporter" do
      let(:platform) { :yaml }
    end

    describe "body" do
      subject { RailsYamlFormat::Exporter.new(language).body }

      it "should be valid yaml that has top level hash only containing the language code" do
        parsed = YAML.load(subject)
        expect(parsed).to be_a Hash
        expect(parsed).to have_key(language.code.to_sym)
      end

      context "with a different language" do
        let(:language) { build_stubbed(:language, code: 'fr') }
        it "has different language code as top level key" do
          expect(YAML.load(subject)).to have_key(:fr)
        end
      end

      describe "the lower level hash" do
        subject { YAML.load(super())[language.code.to_sym] }

        it "should have relevant number of keys" do
          expect(subject).to be_a Hash
          expect(subject.keys.count).to eq localized_texts.length
        end
        it "should have relevant keys which should be strings" do
          localized_texts.each do |text|
            expect(subject.keys).to include(text.key.to_s)
          end
        end
        it "should have relevant values which should be strings" do
          localized_texts.each do |text|
            expect(subject.values).to include(text.other_export.to_s)
          end
        end
        context "with only one key" do
          let(:localized_texts) { [text] }
          let(:text) { build_stubbed(:localized_text) }

          it "should have relevant number of keys" do
            expect(subject).to be_a Hash
            expect(subject.keys.count).to eq 1
          end
          it "should have relevant key" do
            expect(subject.keys).to include(text.key.to_sym)
          end
          it "should have relevant value" do
            expect(subject.values).to include(text.other_export.to_s)
          end
        end
      end
    end
  end
end
