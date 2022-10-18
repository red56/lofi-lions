# frozen_string_literal: true

# requires project_language and params[:flow]
module NextLocalizedText
  protected

  def next_localized_text_or_project_language_path(key)
    if params[:flow].present? && (next_text = next_localized_text(key))
      flow_localized_text_path(next_text, flow: params[:flow])
    else
      project_language_path(project_language)
    end
  end

  def next_localized_text(key)
    return nil unless params[:flow].present?

    if (next_localized_text = next_localized_text_after(key))
      next_localized_text
    else
      next_localized_text_start_again
    end
  end

  def next_localized_text_start_again
    next_localized_text = next_localized_text_after(nil)
    flash.notice = if next_localized_text
                     "Last text reached. Starting again at the beginning"
                   else
                     "Last text reached. No more needing attention."
                   end
    next_localized_text
  end

  def next_localized_text_after(key)
    project_language.next_localized_text(key, all: (params[:flow] == "all"))
  end
end
