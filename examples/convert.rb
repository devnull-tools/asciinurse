require 'asciidoctor'
require_relative '../lib/asciinurse'

Asciidoctor.convert_file ARGV[0], {
                                    header_footer: true,
                                    safe: :unsafe
                                }