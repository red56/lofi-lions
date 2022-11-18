# frozen_string_literal: true

module MasterTextTransforms
  class SplitParagraphs < Base
    def transform
      transform_and_create do |new_master_texts|
        non_blank_lines.each_with_index do |para, index|
          new_master_text = create_transformed(new_key: "#{base_key}_P%02d" % (index + 1), new_text: para) do |localized_text|
            raise "#{key} (LocalizedText##{localized_text.id}) wrong number of non_blank_lines (expected #{non_blank_lines.length}, got #{localized_text.non_blank_lines.length})" unless non_blank_lines.length == localized_text.non_blank_lines.length

            localized_text.non_blank_lines[index]
          end
          new_master_texts << new_master_text
        end
      end
    end
  end
end
