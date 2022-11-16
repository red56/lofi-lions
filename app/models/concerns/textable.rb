# frozen_string_literal: true

module Textable
  def non_blank_lines
    raise "non_blank_lines can't deal with pluralizable" if pluralizable

    text.strip.split("\n").map { |t| t.strip.presence }.compact
  end

  # strips bullets from text and normalizes returns to double returns
  def strip_bullets
    raise "strip_bullets can't deal with pluralizable" if pluralizable

    self.text = non_blank_lines.map { |line| line.sub(/^\s*[*] /, "") }.join("\n\n")
  end
end
