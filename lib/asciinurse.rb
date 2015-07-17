require 'asciidoctor'
require 'yaml'
require 'fileutils'
require 'set'

require_relative 'asciinurse/version'

ENV['ASCIINURSE_USER_DIR'] ||= ('%s/.asciinurse' % ENV['HOME'])

module Asciinurse

  RESOURCE_PRECEDENCE = [
      ENV['ASCIINURSE_USER_DIR'],
      File.expand_path(File.dirname(__FILE__) + '/..')
  ]

  def self.add_custom_path(path)
    RESOURCE_PRECEDENCE.insert 1, path
  end

  def self.find(path)
    result = []
    RESOURCE_PRECEDENCE.each do |basedir|
      file = "#{basedir}/#{path}"
      result << file if File.exist? file
    end
    result
  end

  def self.find_resource(path)
    find("resources/#{path}").first
  end

  def self.read_resource(path)
    IO.read find_resource(path)
  end

  CONFIG = {}

  def self.config(key)
    result = CONFIG
    key.to_s.split('.').each do |obj|
      result = result[obj]
    end
    result
  end

  # reverse order so custom config can take precedence over built-in config
  find('config/asciinurse.yml').reverse_each do |file|
    CONFIG.merge! YAML::load_file(file)
  end

  TEMP_DIRS = Set::new

  def self.tmp_dir(document)
    basedir = document.attributes['docdir']
    tmpdir = "#{basedir}/tmp"
    FileUtils.mkpath tmpdir unless File.exist? tmpdir
    TEMP_DIRS << tmpdir if document.attributes['backend'] == 'pdf'
    tmpdir
  end

  at_exit do
    TEMP_DIRS.each do |tmpdir|
      FileUtils.rmtree tmpdir
    end
  end

end

require_relative 'asciinurse/extensions/charts/extension'

if File.exist? ENV['ASCIINURSE_USER_DIR']
  custom_script = '%s/asciinurse.rb' % ENV['ASCIINURSE_USER_DIR']
  require custom_script if File.exist? custom_script
end
