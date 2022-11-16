# frozen_string_literal: true

class MasterText < ApplicationRecord
  include Textable

  MARKDOWN_FORMAT = "markdown"
  PLAIN_FORMAT = "plain"

  belongs_to :project, inverse_of: :master_texts, optional: false
  has_many :localized_texts, inverse_of: :master_text, dependent: :destroy
  has_many :key_placements, inverse_of: :master_text
  has_many :views, through: :key_placements

  # like a scope but doesn't return an association proxy
  def self.with_matching_keys(regexp)
    select { |mt| mt.key.match?(regexp) }
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

  # transforms:
  def md_to_paragraphs!
    raise "md_to_paragraphs! can't deal with pluralizable" if pluralizable?
    return if key.starts_with?("ΩΩΩ_")

    if non_blank_lines.length == 1
      logger.warn "MasterText[#{key}].md_to_paragraphs! but has has zero paragraphs"
      return
    end

    base_key = key.gsub(/_md$/, "")
    new_keys = []
    transaction do
      non_blank_lines.each_with_index do |para, index|
        new_key = "#{base_key}_p%02d" % (index + 1)
        new_keys << new_key
        new_master_text = project.master_texts.create!(key: new_key, text: para, views: views, comment: comment)
        localized_texts.each do |localized_text|
          new_master_text.localized_texts.create!(project_language: localized_text.project_language, text: localized_text.non_blank_lines[index])
        end
      end
      update!(key: "ΩΩΩ_#{key}")
    end
    new_keys
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
