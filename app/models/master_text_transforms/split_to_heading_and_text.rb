# frozen_string_literal: true

module MasterTextTransforms
  class SplitToHeadingAndText < Base
    def transform
      transform_and_create do |new_master_texts|
        heading, body = first_and_rest_of_blank_lines

        new_master_texts << create_transformed(new_key: "#{base_key}_heading", new_text: self.class.strip_heading_markup_and_number(heading)) do |localized_text|
          self.class.strip_heading_markup_and_number(localized_text.first_and_rest_of_blank_lines.first)
        end
        new_master_texts << create_transformed(new_key: "#{base_key}_text", new_text: self.class.strip_bullets(body)) do |localized_text|
          self.class.strip_bullets(localized_text.first_and_rest_of_blank_lines.second)
        end
      end
    end
  end
end
