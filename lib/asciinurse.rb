require 'asciidoctor'

require_relative 'asciinurse/version'
require_relative 'asciinurse/extensions/charts/chart_extension'

ENV['ASCIINURSE_USER_DIR'] ||= ('%s/.asciinurse' % ENV['HOME'])
if File.exist? ENV['ASCIINURSE_USER_DIR']
  custom_script = '%s/asciinurse.rb' % ENV['ASCIINURSE_USER_DIR']
  require custom_script if File.exist? custom_script
end

module Asciinurse

  RESOURCE_PRECEDENCE = [
      ENV['ASCIINURSE_USER_DIR'],
      File.expand_path(File.dirname(__FILE__) + '/..')
  ]

  def self.find_resource(*path)
    RESOURCE_PRECEDENCE.each do |basedir|
      file = "#{basedir}/resources/#{path.join('/')}"
      return file if File.exist? file
    end
    return nil
  end

  def self.read_resource(*path)
    IO.read find_resource(*path)
  end

end
