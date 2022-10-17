module ImagesHelper
  def favicon(suffix = ".ico")
    asset_path("favicons/lofi-#{Rails.application.pseudo_env}#{suffix}")
  end
end
