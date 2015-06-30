class ExportsController < ApplicationController
  before_filter :load_language

  def android
    export
  end

  def ios
    export
  end

  protected

  def export(platform = params[:action])
    data, path, type = Export::Exporter.export(@language, platform)
    headers["X-Path"] = path
    send_data data, type: type, disposition: "inline", filename: ::File.basename(path)
  end

  def load_language
    code = params[:language]
    @language = Language.where(code: code).first
    return load_language_fallback(code) if @language.nil?
  end

  def load_language_fallback(code)
    if code == "en"
      @language = Language.en if code == "en"
    else
      render text: "Language #{code} not found", status: 404
      return false
    end
  end
end
