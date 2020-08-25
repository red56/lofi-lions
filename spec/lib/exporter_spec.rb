require 'rails_helper'

shared_examples_for "a BaseExporter" do

  specify "should find correct class" do
    klass = BaseExporter.class_for(platform)
    expect(klass).not_to be_nil
    expect(klass).not_to eq BaseExporter
    expect(klass).to be < BaseExporter

  end
  describe "instance" do
    subject { BaseExporter.class_for(platform).new(language, project) }

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
  let(:project) { build_stubbed(:project) }
  let(:language) { build_stubbed(:language, code: 'la') }
  let(:project_language) { build_stubbed(:project_language, project: project, language: language) }
  let(:master_texts) { build_stubbed_list(:master_text, 3, project: project) }
  let(:localized_texts) { master_texts.map { |mt| build_stubbed(:stubbed_localized_text, master_text: mt,
    project_language: project_language) } }
  before {
    allow(project_language).to receive(:localized_texts_with_fallback).and_return(localized_texts)
    allow(ProjectLanguage).to receive(:where).with(project_id: project.id, language_id: language.id).and_return([project_language])
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
    let(:export) { RailsYamlFormat::Exporter.new(language, project) }
    let(:body) { export.body }

    describe "body" do
      subject { body }

      it "the file should start with expected beginning" do
        expect(subject).to be_a String
        lines = subject.split("\n")
        expect(lines[0]).to eq("---")
        expect(lines[1]).to eq("la:")
      end

      it "should be valid yaml that has top level hash only containing the language code" do
        parsed = YAML.load(subject)
        expect(parsed).to be_a Hash
        expect(parsed).to have_key(language.code)
      end


      context "with a different language" do
        let(:language) { build_stubbed(:language, code: 'fr') }
        it "has different language code as top level key" do
          expect(YAML.load(subject)).to have_key("fr")
        end
      end
    end

    describe "the lower level hash" do
      subject { YAML.load(body)[language.code] }

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
          expect(subject.keys).to include(text.key)
        end
        it "should have relevant value" do
          expect(subject.values).to include(text.other_export.to_s)
        end
      end
    end
  end
end
