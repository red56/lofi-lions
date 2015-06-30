require "spec_helper"

describe 'Yaml file parser' do
  let(:file_path) { File.expand_path("../../fixtures/simple_strings.yml", __FILE__) }
  let(:parsed) { RailsYamlFormat::YamlFile.parse(File.new(file_path)) }

  it "should return keys in UTF-8" do
    expect(parsed.keys.first.encoding).to eq(Encoding::UTF_8)
  end

  it "can give a count of the keys" do
    expect(parsed.keys.count).to eq(3)
  end

  it "can give a list of the keys" do
    expect(parsed.keys).to eq(["Adding", "Almost done", "Done"])
  end

  it "returns localizations" do
    expect(parsed.localizations).to be_a Array
    expect(parsed.localizations.length).to eq(3)
    expect(parsed.localizations.first).to be_a Localization
  end

  it "supports close" do
    expect{parsed.close}.not_to raise_exception
  end

  it "supports being given an Uploaded File" do
    uploaded = ActionDispatch::Http::UploadedFile.new(tempfile: file_path)
    expect(RailsYamlFormat::YamlFile.parse(uploaded).localizations).to be_a Array
  end
end
