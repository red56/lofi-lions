# frozen_string_literal: true

module MasterTextTransforms
  class SplitToSections < MasterTextTransforms::Base
    def transform
      transform_and_create do |new_master_texts, base|
        current_section_number = 0
        current_section_para_count = 0
        non_blank_lines.each_with_index do |line, index|
          stripped = self.class.strip_heading_markup_and_number(line)
          is_heading = stripped != line
          if is_heading
            current_section_number += 1
            current_section_para_count = 0
          elsif current_section_number.positive?
            current_section_para_count += 1
          else
            # first section without heading
            current_section_number = 1
            current_section_para_count = 1
          end

          new_key = if is_heading
                      "#{base}_s#{current_section_number}_heading"
                    else
                      "#{base}_s#{current_section_number}_p#{current_section_para_count}"
                    end
          new_master_text = create_transformed(new_key: new_key, new_text: stripped) do |localized_text|
            raise "#{key} (LocalizedText##{localized_text.id}) wrong number of non_blank_lines (expected #{non_blank_lines.length}, got #{localized_text.non_blank_lines.length})" unless non_blank_lines.length == localized_text.non_blank_lines.length

            l_text = localized_text.non_blank_lines[index]
            l_stripped = self.class.strip_heading_markup_and_number(l_text)
            if is_heading
              raise "#{key} (LocalizedText##{localized_text.id}) (expected heading, got #{l_text})" if l_text == l_stripped

              l_stripped
            else
              raise "#{key} (LocalizedText##{localized_text.id}) (expected non-heading, got #{l_text})" if l_text != l_stripped

              l_text
            end
          end
          new_master_texts << new_master_text
        end
      end
    end
  end
end
