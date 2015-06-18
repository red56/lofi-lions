require "spec_helper"

describe 'Strings file parser' do
  let(:file_path) { File.expand_path("../../fixtures/simple_strings.yml", __FILE__) }
  let(:parsed) { RailsYamlFormat::ResourceFile.parse(File.new(file_path)) }

  it "should return keys in UTF-8" do
    expect(parsed.keys.first.encoding).to eq(Encoding::UTF_8)
  end

  it "can give a count of the keys" do
    expect(parsed.keys.count).to eq(3)
  end

  it "can give a list of the keys" do
    expect(parsed.keys).to eq(["Adding", "Almost done", "Done"])
  end


end
