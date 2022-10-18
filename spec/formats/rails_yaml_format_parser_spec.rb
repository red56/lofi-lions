# frozen_string_literal: true

require "spec_helper"

describe "Yaml file parser" do
  subject(:yaml_file) { RailsYamlFormat::YamlFile.parse(File.new(file_path)) }

  let(:file_path) { File.expand_path("../fixtures/simple_strings.yml", __dir__) }

  it "returns keys in UTF-8" do
    expect(yaml_file.keys.first.encoding).to eq(Encoding::UTF_8)
  end

  it "can give a count of the keys" do
    expect(yaml_file.keys.count).to eq(3)
  end

  it "can give a list of the keys" do
    expect(yaml_file.keys).to eq(["Adding", "Almost done", "Done"])
  end

  it "returns localizations" do
    expect(yaml_file.localizations).to be_a Array
    expect(yaml_file.localizations.length).to eq(3)
    expect(yaml_file.localizations.first).to be_a Localization
  end

  it "supports close" do
    expect { yaml_file.close }.not_to raise_exception
  end

  it "supports being given an Uploaded File" do
    uploaded = ActionDispatch::Http::UploadedFile.new(tempfile: file_path)
    expect(RailsYamlFormat::YamlFile.parse(uploaded).localizations).to be_a Array
  end

  context "with nested keys" do
    let(:file_path) { File.expand_path("../fixtures/strings_with_nested.yml", __dir__) }

    it "converts them" do
      expect(yaml_file.keys).to contain_exactly("activerecord/attributes/user/email", "activerecord/attributes/user/password")
    end
  end
end
