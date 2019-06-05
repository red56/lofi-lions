require 'rails_helper'

describe MasterText, :type => :model do
  describe "validations" do
    let(:master_text) { build(:master_text) }
    it "basically works" do
      expect(master_text).to be_valid
    end
    it "requires key" do
      master_text.key = nil
      expect(master_text).not_to be_valid
    end
    it "requires key" do
      master_text.key = ''
      expect(master_text).not_to be_valid
    end
    it "requires unique key" do
      master_text.save!
      new_master_text = MasterText.new(key: master_text.key)
      expect(new_master_text).not_to be_valid
    end
    it "requires text" do
      master_text.text = nil
      expect(master_text).not_to be_valid
    end
    it "requires text" do
      master_text.text = ''
      expect(master_text).not_to be_valid
    end
    context "pluralizable" do
      let(:master_text) { build(:master_text, pluralizable: true) }
      it "basically works" do
        expect(master_text).to be_valid
      end
      it "requires key" do
        master_text.key = nil
        expect(master_text).not_to be_valid
      end
      it "requires key" do
        master_text.key = ''
        expect(master_text).not_to be_valid
      end
      it "requires unique key" do
        master_text.save!
        new_master_text = MasterText.new(key: master_text.key)
        expect(new_master_text).not_to be_valid
      end
      it "requires other" do
        master_text.other = ''
        expect(master_text).not_to be_valid
      end
      it "requires a project" do
        master_text.project_id = nil
        expect(master_text).not_to be_valid
      end
    end
  end

  context "pluralizable" do
    let(:master_text) { build(:master_text, pluralizable: true) }
    it "can't return text" do
      expect {
        master_text.text
      }.to raise_error(/when pluralizable/)
    end

  end

  describe "text_changed?" do
    shared_examples_for "shared_text_changed" do
      it "is false when key changing" do
        master_text.key = "flong"
        expect(master_text.text_changed?).to be_falsey
      end
      it "is false when nothing changing" do
        expect(master_text.text_changed?).to be_falsey
      end
      it "is true when pluralizable" do
        master_text.pluralizable = !master_text.pluralizable
        expect(master_text.text_changed?).to be_truthy
      end
    end
    context "when unpluralized" do
      let(:master_text) { create(:master_text, pluralizable: false) }
      it "is true when text changing" do
        master_text.text = "flong"
        expect(master_text.text_changed?).to be_truthy
      end
      include_examples "shared_text_changed"
    end
    context "when pluralized" do
      let(:master_text) { create(:master_text, pluralizable: true) }
      it "is true when one changing" do
        master_text.one = "flong"
        expect(master_text.text_changed?).to be_truthy
      end
      it "is true when other changing" do
        master_text.other = "flong"
        expect(master_text.text_changed?).to be_truthy
      end
      include_examples "shared_text_changed"
    end
  end
  context "#key" do
    let(:existing){create :master_text, project:create(:project)}
    it "must be unique" do
      expect(build(:master_text, key: existing.key, project: existing.project)).not_to be_valid
    end
    it "only unique in same project" do
      expect(build(:master_text, key: existing.key, project: create(:project))).to be_valid
    end
  end

  describe "#markdown?" do
    let(:master_text) { build(:master_text, format: format) }
    subject{master_text}
    context "markdown" do
      let(:format) { MasterText::MARKDOWN_FORMAT }
      it { is_expected.to be_markdown }
    end
    context "plain" do
      let(:format) { MasterText::PLAIN_FORMAT }
      it { is_expected.not_to be_markdown }
    end
  end

  describe "word count" do
    it "counts nothing" do
      master_text = build(:master_text, text: nil)
      expect(master_text.send(:calculate_word_count)).to eq(0)
      master_text = build(:master_text, text: '')
      expect(master_text.send(:calculate_word_count)).to eq(0)
    end
    it "counts a word" do
      master_text = build(:master_text, text: "Oh.")
      expect(master_text.send(:calculate_word_count)).to eq(1)
    end
    it "counts some words" do
      master_text = build(:master_text, text: "Oh, so there you are Mr Jones.")
      expect(master_text.send(:calculate_word_count)).to eq(7)
    end
    it "counts some words in paragraphs or weird spacing" do
      text = <<-TEXT
      Oh, so there you are Mr Jones.
We have been expecting you
\t\tFor some time!
      TEXT
      master_text = build(:master_text, text: text)
      expect(master_text.send(:calculate_word_count)).to eq(15)
    end

    context "when pluralizable" do
      it "counts nothing" do
        master_text = build(:master_text, one: nil, other: nil, pluralizable: true)
        expect(master_text.send(:calculate_word_count)).to eq(0)
      end

      it "counts one" do
        master_text = build(:master_text, one: "a dog", other: "many dogs", pluralizable: true)
        expect(master_text.send(:calculate_word_count)).to eq(4)
      end
      it "counts several" do
        master_text = build(:master_text, one: "this is a carrot", other: "these are some carrots", pluralizable: true)
        expect(master_text.send(:calculate_word_count)).to eq(8)
      end
    end
    it "is stored on save" do
      master_text = create(:master_text, text: "many")
      expect { master_text.update(text: "many dogs are lovely.") }.to change {master_text.reload[:word_count]}.from(1).to(4)
    end
  end
end
