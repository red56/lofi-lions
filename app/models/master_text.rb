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

  # transforms:
  def md_to_paragraphs!(base_key: nil)
    transform_and_create(base_key: base_key) do |new_master_texts, base|
      non_blank_lines.each_with_index do |para, index|
        new_master_text = create_transformed(new_key: "#{base}_p%02d" % (index + 1), new_text: para) do |localized_text|
          raise "#{key} (LocalizedText##{localized_text.id}) wrong number of non_blank_lines (expected #{non_blank_lines.length}, got #{localized_text.non_blank_lines.length})" unless non_blank_lines.length == localized_text.non_blank_lines.length

          localized_text.non_blank_lines[index]
        end
        new_master_texts << new_master_text
      end
    end
  end

  def md_to_heading_and_body!(base_key: nil)
    transform_and_create(base_key: base_key) do |new_master_texts, base|
      heading, body = first_and_rest_of_blank_lines

      new_master_texts << create_transformed(new_key: "#{base}_heading", new_text: self.class.strip_heading_markup_and_number(heading)) do |localized_text|
        self.class.strip_heading_markup_and_number(localized_text.first_and_rest_of_blank_lines.first)
      end
      new_master_texts << create_transformed(new_key: "#{base}_body", new_text: self.class.strip_bullets(body)) do |localized_text|
        self.class.strip_bullets(localized_text.first_and_rest_of_blank_lines.second)
      end
    end
  end

  private

  def transform_and_create(base_key:)
    raise "can't deal with pluralizable" if pluralizable?
    return if key.starts_with?("ΩΩΩ_")

    if non_blank_lines.length == 1
      logger.warn "can't transform - has zero paragraphs"
      return
    end

    base_key ||= key.gsub(/_md$/, "")
    new_master_texts = []
    transaction do
      yield [new_master_texts, base_key]
      update!(key: "ΩΩΩ_#{key}")
    end
    new_master_texts
  end

  def create_transformed(new_key:, new_text:)
    new_master_text = project.master_texts.create!(key: new_key, text: new_text, views: views, comment: comment)
    localized_texts.each do |localized_text|
      new_master_text.localized_texts.create!(project_language: localized_text.project_language, text: yield(localized_text))
    end
    new_master_text
  end

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
