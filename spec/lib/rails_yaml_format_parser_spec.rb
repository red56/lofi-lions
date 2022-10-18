require "spec_helper"

describe "Yaml file parser" do
  subject { RailsYamlFormat::YamlFile.parse(File.new(file_path)) }

  let(:file_path) { File.expand_path("../../fixtures/simple_strings.yml", __FILE__) }

  it "should return keys in UTF-8" do
    expect(subject.keys.first.encoding).to eq(Encoding::UTF_8)
  end

  it "can give a count of the keys" do
    expect(subject.keys.count).to eq(3)
  end

  it "can give a list of the keys" do
    expect(subject.keys).to eq(["Adding", "Almost done", "Done"])
  end

  it "returns localizations" do
    expect(subject.localizations).to be_a Array
    expect(subject.localizations.length).to eq(3)
    expect(subject.localizations.first).to be_a Localization
  end

  it "supports close" do
    expect { subject.close }.not_to raise_exception
  end

  it "supports being given an Uploaded File" do
    uploaded = ActionDispatch::Http::UploadedFile.new(tempfile: file_path)
    expect(RailsYamlFormat::YamlFile.parse(uploaded).localizations).to be_a Array
  end

  context "with nested keys" do
    let(:file_path) { File.expand_path("../../fixtures/strings_with_nested.yml", __FILE__) }

    it "converts them" do
      expect(subject.keys).to contain_exactly("activerecord/attributes/user/email", "activerecord/attributes/user/password")
    end
  end
end
