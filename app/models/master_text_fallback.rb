#Not really sure if this needs to exist. see note at ProjectLanguage#localized_texts_with_fallback
class MasterTextFallback
  def initialize(master_text)
    @master_text = master_text
  end

  def key
    @master_text.key
  end

  def pluralizable
    @master_text.pluralizable
  end

  def one
    @master_text.one
  end

  def other_export
    @master_text.other
  end

  Language::PLURAL_FORMS.reject { |form| form == :one }.each do |form|
    module_eval (<<-RB)
        def #{form}
          @master_text.other
        end
    RB
  end
end
