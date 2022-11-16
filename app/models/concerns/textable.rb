# frozen_string_literal: true

module Textable
  def non_blank_lines
    raise "non_blank_lines can't deal with pluralizable" if pluralizable

    text.strip.split("\n").map { |t| t.strip.presence }.compact
  end
end
