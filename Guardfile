# A sample Guardfile
# More info at https://github.com/guard/guard#readme

interactor :off

guard 'rails', server: :thin, port: 3010 do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
end

guard 'livereload', port: 35740 do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
end
