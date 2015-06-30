require 'spec_helper'

shared_examples_for "a BaseExporter" do

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

describe "Exporters" do
  let(:language) { double(Language, localized_texts_with_fallback: localized_texts, code: 'la') }
  let(:localized_texts) { build_stubbed_list(:localized_text, 3) }
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
end
