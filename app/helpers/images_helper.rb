module ImagesHelper
  def favicon(suffix = ".ico")
    asset_path("favicons/lofi-#{Rails.env}#{suffix}")
  end
end
