# frozen_string_literal: true

module MasterTextTransforms
  class Base
    include Textable

    # @return [MasterText]
    attr_reader :master_text
    # @return [String]
    attr_reader :base_key

    def initialize(master_text, base_key: nil)
      @master_text = master_text
      @base_key = base_key || key.gsub(/_md$/, "")
    end

    private

    delegate :key, :logger, :pluralizable?, :project, :non_blank_lines, :text, :transaction,
             to: :master_text

    def transform_and_create
      raise "can't deal with pluralizable" if pluralizable?
      return if key.starts_with?("ΩΩΩ_")

      if non_blank_lines.length == 1
        logger.warn "can't transform - has zero paragraphs"
        return
      end

      new_master_texts = []
      transaction do
        yield new_master_texts
        master_text.update!(key: "ΩΩΩ_#{key}")
      end
      new_master_texts
    end

    def create_transformed(new_key:, new_text:)
      new_master_text = project.master_texts.create!(key: new_key, text: new_text, views: master_text.views, comment: master_text.comment)
      master_text.localized_texts.each do |localized_text|
        new_master_text.localized_texts.create!(project_language: localized_text.project_language, text: yield(localized_text))
      end
      new_master_text
    end
  end
end
