# frozen_string_literal: true

class MasterText < ApplicationRecord
  include Textable

  MARKDOWN_FORMAT = "markdown"
  PLAIN_FORMAT = "plain"

  belongs_to :project, inverse_of: :master_texts, optional: false
  has_many :localized_texts, inverse_of: :master_text, dependent: :destroy
  has_many :key_placements, inverse_of: :master_text
  has_many :views, through: :key_placements

  # like a scope but doesn't always return an association proxy
  # Either use with one regexps or more than one string
  def self.with_keys(*args)
    if args.length == 1 && args.first.is_a?(Regexp)
      select { |mt| mt.key.match?(args.first) }
    else
      where(key: args)
    end
  end

  validates :key, presence: true
  validates_uniqueness_of :key, scope: :project_id
  validates :other, presence: true

  before_save do
    self.word_count = calculate_word_count
  end

  def text= text
    self.other = text
  end

  def text
    raise Exception.new("Don't use text when pluralizable") if self.pluralizable

    self.other
  end

  def text_changed?
    return true if self.other_changed?
    return true if self.one_changed?
    return true if self.pluralizable_changed?

    false
  end

  def markdown?
    format == MARKDOWN_FORMAT
  end

  def md_to_paragraphs!(base_key: nil)
    MasterTextTransforms::SplitParagraphs.new(self, base_key: base_key).transform
  end

  def md_to_heading_and_body!(base_key: nil)
    MasterTextTransforms::SplitToHeadingAndBody.new(self, base_key: base_key).transform
  end

  def split_to_sections(base_key: nil)
    MasterTextTransforms::SplitToSections.new(self, base_key: base_key).transform
  end

  private

  def calculate_word_count
    if pluralizable?
      count_words(one) + count_words(other)
    else
      count_words(text)
    end
  end

  def count_words(target_text)
    return 0 unless target_text.present?

    target_text.strip.split(/\s+/).length
  end
end
