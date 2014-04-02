require 'export'

class ExportsController < ApplicationController
  before_filter :load_language

  def android
    export#(:android)
  end

  def ios
    export
  end

  protected

  def export(platform = params[:action])
    data, path, type = Export.create(@language, platform)
    headers["X-Path"] = path
    send_data data, type: type, disposition: "inline", filename: ::File.basename(path)
  end

  def load_language
    @language = Language.where(code: params[:language]).first
  end
end
