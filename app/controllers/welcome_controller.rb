class WelcomeController < ApplicationController
  def index
    return redirect_to new_user_session_path unless user_signed_in?
    return if current_user.is_developer?
    return redirect_to users_path if current_user.is_administrator? && ! current_user.edits_master_text?
    if language = current_user.languages.first
      return redirect_to language_texts_path(language)
    end
    redirect_to master_texts_path
  end

end
