# frozen_string_literal: true

module Textable
  extend ActiveSupport::Concern

  class_methods do
    def non_blank_lines(text)
      text.strip.split("\n").map { |t| t.strip.presence }.compact
    end

    def first_and_rest_of_blank_lines(text)
      first, *rest = non_blank_lines(text)
      [first, rest.join("\n\n")]
    end

    def strip_bullets(text)
      non_blank_lines(text).map { |line| line.sub(/^\s*[*] /, "") }.join("\n\n")
    end

    def strip_heading_markup_and_number(text)
      text.sub(/^(#+\s+)?(\d+[.]\s+)?/, "")
    end
  end

  def non_blank_lines
    raise "non_blank_lines can't deal with pluralizable" if pluralizable

    @non_blank_lines ||= self.class.non_blank_lines(text)
  end

  def first_and_rest_of_blank_lines
    self.class.first_and_rest_of_blank_lines(text)
  end

  # strips bullets from text and normalizes returns to double returns
  def strip_bullets
    raise "strip_bullets can't deal with pluralizable" if pluralizable

    self.text = self.class.strip_bullets(text)
  end

  def strip_heading_markup_and_number
    raise "strip_heading_markup_and_number can't deal with pluralizable" if pluralizable

    self.text = self.class.strip_heading_markup_and_number(text)
  end
end
