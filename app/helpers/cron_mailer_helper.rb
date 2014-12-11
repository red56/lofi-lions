module CronMailerHelper
  def colourize_translation_status(texts, needing)
    percent = ((needing.to_f / texts.length.to_f) * 100.0).round
    (%(<span style="color: #{percentage_colour(percent)}">) << needing.to_s.ljust(4, ' ') << " (" << percent.to_s << "%)" << %(</span>)).html_safe
  end

    # https://github.com/mbostock/d3/wiki/Ordinal-Scales
  def percentage_colour(used_percent)
    if used_percent < 10
      '#31a354'
    elsif used_percent < 20
      '#74c476'
    elsif used_percent < 30
      '#fdae6b'
    elsif used_percent < 40
      '#fd8d3c'
    elsif used_percent < 50
      '#e6550d'
    else
      '#d62728'
    end
  end

end