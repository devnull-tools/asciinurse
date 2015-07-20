# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciinurse/version'

Gem::Specification.new do |spec|
  spec.name          = 'asciinurse'
  spec.version       = Asciinurse::VERSION
  spec.authors       = ['Ataxexe']
  spec.email         = ['ataxexe@devnull.tools']

  spec.summary       = "The best Asciidoctor's assistant"
  spec.homepage      = 'http://devnull.tools'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'asciidoctor', '~> 1.5'
  spec.add_dependency 'asciidoctor-pdf', '~> 1.5.0.alpha.7'
  spec.add_dependency 'i18n', '~> 0.7.0'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
end
