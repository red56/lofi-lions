# frozen_string_literal: true

require "rails_helper"

shared_examples_for "a BaseExporter" do
  specify "should find correct class" do
    klass = BaseExporter.class_for(platform)
    expect(klass).not_to be_nil
    expect(klass).not_to eq BaseExporter
    expect(klass).to be < BaseExporter
  end

  describe "instance" do
    subject(:base_exporter) { BaseExporter.class_for(platform).new(language, project) }

    it "responds to path" do
      expect(base_exporter.path).to be_a String
    end

    it "responds to content_type" do
      expect(base_exporter.content_type).to be_a String
    end

    it "responds to body_for(texts)" do
      expect(base_exporter.body_for(localized_texts)).to be_a String
    end

    it "responds to body" do
      expect(base_exporter.body).to be_a String
    end
  end
end

describe "Exporters" do
  let(:project) { build_stubbed(:project) }
  let(:language) { build_stubbed(:language, code: "la") }
  let(:project_language) { build_stubbed(:project_language, project: project, language: language) }
  let(:master_texts) { build_stubbed_list(:master_text, 3, project: project) }
  let(:localized_texts) {
    master_texts.map { |mt|
      build_stubbed(:stubbed_localized_text, master_text: mt,
                                             project_language: project_language)
    }
  }

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
    let(:export) { described_class.new(language, project) }
    let(:body) { export.body }

    describe "the body" do
      it "starts with expected beginning" do
        expect(body).to be_a String
        lines = body.split("\n")
        expect(lines[0]).to eq("---")
        expect(lines[1]).to eq("la:")
      end

      it "is valid yaml that has top level hash only containing the language code" do
        parsed = YAML.safe_load(body)
        expect(parsed).to be_a Hash
        expect(parsed).to have_key(language.code)
      end

      context "with a different language" do
        let(:language) { build_stubbed(:language, code: "fr") }

        it "has different language code as top level key" do
          expect(YAML.safe_load(body)).to have_key("fr")
        end
      end
    end

    describe "the lower level hash" do
      subject(:embedded_hash) { YAML.safe_load(body)[language.code] }

      it "has relevant number of keys" do
        expect(embedded_hash).to be_a Hash
        expect(embedded_hash.keys.count).to eq localized_texts.length
      end

      it "has relevant keys which should be strings" do
        localized_texts.each do |text|
          expect(embedded_hash.keys).to include(text.key.to_s)
        end
      end

      it "has relevant values which should be strings" do
        localized_texts.each do |text|
          expect(embedded_hash.values).to include(text.other_export.to_s)
        end
      end

      context "with only one key" do
        let(:localized_texts) { [text] }
        let(:text) { build_stubbed(:localized_text) }

        it "has relevant number of keys" do
          expect(embedded_hash).to be_a Hash
          expect(embedded_hash.keys.count).to eq 1
        end

        it "has relevant key" do
          expect(embedded_hash.keys).to include(text.key)
        end

        it "has relevant value" do
          expect(embedded_hash.values).to include(text.other_export.to_s)
        end
      end
    end

    describe "with an (encoded) nested hash" do
      subject(:loaded_yaml) { YAML.safe_load(body)[language.code] }

      let(:master_text1) { build_stubbed(:master_text, project: project, key: "activerecord/attributes/user/email") }
      let(:master_text2) { build_stubbed(:master_text, project: project, key: "activerecord/attributes/user/password") }
      let(:master_text3) { build_stubbed(:master_text, project: project, key: "activerecord.attributes.project.name") }
      let(:master_texts) { [master_text1, master_text2, master_text3] }
      let(:localized_texts) {
        master_texts.map { |mt|
          build_stubbed(:stubbed_localized_text, master_text: mt,
                                                 project_language: project_language)
        }
      }

      it "produces actual nested output" do
        expect(loaded_yaml.keys).to contain_exactly("activerecord")
        expect(loaded_yaml["activerecord"]["attributes"].keys).to contain_exactly("user", "project")
        expect(loaded_yaml["activerecord"]["attributes"]["user"].keys).to contain_exactly("email", "password")
      end
    end
  end
end
