require 'asciidoctor'
require 'asciidoctor-pdf'
require_relative '../../lib/asciinurse'

Asciidoctor.convert_file ARGV[0], header_footer: true, safe: :unsafe
Asciidoctor.convert_file ARGV[0], backend: 'pdf', header_footer: true, safe: :unsafe
