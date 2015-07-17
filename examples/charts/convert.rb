require 'asciidoctor'
require 'asciidoctor-pdf'
require_relative '../../lib/asciinurse'

Dir['*.adoc'].each do |file|
  Asciidoctor.convert_file file, header_footer: true, safe: :unsafe
  #Asciidoctor.convert_file file, backend: 'pdf', header_footer: true, safe: :unsafe
end