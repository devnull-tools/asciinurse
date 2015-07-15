require 'asciidoctor/extensions'

require_relative 'chart_data'

Asciidoctor::Extensions.register do |registry|
  engine = registry.document.attributes['charts'] || Asciinurse.config(:charts)
  require_relative engine
  registry.block_macro Asciinurse::Chart::ChartBlockMacro
  registry.docinfo_processor Asciinurse::Chart::ChartAssetsDocinfoProcessor
end
