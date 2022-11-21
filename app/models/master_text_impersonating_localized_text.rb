# frozen_string_literal: true

class MasterTextImpersonatingLocalizedText
  # @return [MasterText]
  attr_reader :master_text

  def initialize(master_text)
    @master_text = master_text
  end

  delegate :key, :one, :pluralizable, to: :master_text

  def other_export
    other
  end

  Language::PLURAL_FORMS.reject { |form| form == :one }.each do |form|
    module_eval (<<-RB)
        def #{form}
          master_text.other
        end
    RB
  end
end
