# frozen_string_literal: true

# a master text with all the characters changed to x - useful for visual/manual testing
class MasterTextAsXx
  # @return [MasterText]
  attr_reader :master_text

  def initialize(master_text)
    @master_text = master_text
  end

  delegate :key, :pluralizable, to: :master_text

  def one
    replace_with_xx(master_text.one)
  end

  def other_export
    replace_with_xx(master_text.other)
  end

  # rubocop:disable Style/DocumentDynamicEvalDefinition
  Language::PLURAL_FORMS.reject { |form| form == :one }.each do |form|
    module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{form}
          other_export
        end
    RUBY
  end
  # rubocop:enable Style/DocumentDynamicEvalDefinition

  private

  def replace_with_xx(text)
    text.gsub(/[A-Z]/, "X").gsub(/[a-z]/, "x")
  end
end
