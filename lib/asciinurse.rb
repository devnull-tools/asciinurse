require 'asciidoctor'
require 'yaml'

require_relative 'asciinurse/version'

ENV['ASCIINURSE_USER_DIR'] ||= ('%s/.asciinurse' % ENV['HOME'])

module Asciinurse

  RESOURCE_PRECEDENCE = [
      ENV['ASCIINURSE_USER_DIR'],
      File.expand_path(File.dirname(__FILE__) + '/..')
  ]

  def self.find(*path)
    result = []
    RESOURCE_PRECEDENCE.each do |basedir|
      file = "#{basedir}/#{path.join('/')}"
      result << file if File.exist? file
    end
    result
  end

  def self.find_resource(*path)
    find(:resources, *path).first
  end

  def self.read_resource(*path)
    IO.read find_resource(*path)
  end

  CONFIG = {}

  def self.config(key)
    CONFIG[key.to_s]
  end

  # reverse order so custom config can take precedence over built-in config
  find(:config, 'asciinurse.yml').reverse_each do |file|
    CONFIG.merge! YAML::load_file(file)
  end

end

require_relative 'asciinurse/extensions/charts/extension'

if File.exist? ENV['ASCIINURSE_USER_DIR']
  custom_script = '%s/asciinurse.rb' % ENV['ASCIINURSE_USER_DIR']
  require custom_script if File.exist? custom_script
end