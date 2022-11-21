# frozen_string_literal: true

module MasterTextTransforms
  class SplitToSections < Base
    attr_reader :current_section_number, :current_section_para_count

    def transform
      @current_section_number = 0
      @current_section_para_count = 0

      transform_and_create do |new_master_texts|
        non_blank_lines.each_with_index do |line, index|
          stripped = self.class.strip_heading_markup_and_number(line)
          is_heading = stripped != line
          if is_heading
            next_section
          else
            next_paragraph
          end

          new_key = new_key(is_heading)
          new_master_text = create_transformed(new_key: new_key, new_text: stripped) do |localized_text|
            transform_localized_text(localized_text, index: index, is_heading: is_heading)
          end
          new_master_texts << new_master_text
        end
      end
    end

    private

    def new_key(is_heading)
      if is_heading
        "#{base_key}_s#{current_section_number}_heading"
      else
        "#{base_key}_s#{current_section_number}_p#{current_section_para_count}"
      end
    end

    def next_paragraph
      if current_section_number.positive?
        @current_section_para_count += 1
      else
        # first section without heading
        @current_section_number = 1
        @current_section_para_count = 1
      end
    end

    def next_section
      @current_section_number += 1
      @current_section_para_count = 0
    end

    def transform_localized_text(localized_text, index:, is_heading:)
      check_lengths!(localized_text)

      text_line = localized_text.non_blank_lines[index]
      text_line_stripped_of_heading = self.class.strip_heading_markup_and_number(text_line)
      transform_text_line(text_line, text_line_stripped_of_heading, should_be_heading: is_heading, localized_text: localized_text)
    end

    def transform_text_line(text_line, text_line_stripped_of_heading, should_be_heading:, localized_text:)
      if should_be_heading && text_line == text_line_stripped_of_heading
        exit_with_error "#{key} (LocalizedText##{localized_text.id}) (expected heading, got #{text_line})"
      elsif should_be_heading
        text_line_stripped_of_heading
      elsif !should_be_heading && text_line != text_line_stripped_of_heading
        exit_with_error "#{key} (LocalizedText##{localized_text.id}) (expected non-heading, got #{text_line})" if text_line != text_line_stripped_of_heading
      else
        text_line
      end
    end
  end
end
