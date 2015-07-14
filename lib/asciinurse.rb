require 'asciidoctor'

require_relative 'asciinurse/version'
require_relative 'asciinurse/extensions/charts/chart_extension'

ENV['ASCIINURSE_USER_DIR'] ||= ('%s/.asciinurse' % ENV['HOME'])
if File.exist? ENV['ASCIINURSE_USER_DIR']
  custom_script = '%s/asciinurse.rb' % ENV['ASCIINURSE_USER_DIR']
  require custom_script if File.exist? custom_script
end
