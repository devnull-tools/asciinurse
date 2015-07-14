require 'asciidoctor/extensions'
require 'fileutils'

module Asciinurse
  module Chart
    class ChartBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      use_dsl
      named :chart
      name_positional_attributes 'type', 'width', 'height'

      def process(parent, target, attrs)
        document = parent.document
        data_path = parent.normalize_asset_path(target, 'target')
        backend = document.attributes['backend']
        id = '%s_%s' % [attrs['title'].gsub(/\W/, '_').downcase, rand(10000)]

        data = parent.read_asset(data_path, warn_on_failure: true, normalize: true)
        if backend == 'pdf'
          raise 'Sorry!'
        elsif backend == 'html5'
          result = create_html_content id, data
          create_pass_block parent, result, attrs, subs: nil
        end
      end

      def create_html_content(id, data)
        %(
        <div id='#{id}'>
        <script type="text/javascript">
          $(function () {
              $('##{id}').highcharts(#{data});
          });
        </script>
        )
      end
    end

    class ChartAssetsDocinfoProcessor < Asciidoctor::Extensions::DocinfoProcessor
      use_dsl
      at_location :header

      SCRIPTS = %w{jquery.min.js highcharts.min.js global.js}

      def process(doc)
        if doc.attributes['backend'] == 'html5'
          (SCRIPTS.collect do |script|
            %(
              <script type="text/javascript">
                #{read_resource script}
              </script>
            )
          end).join $/
        end
      end

      def read_resource(resource_name)
        basedir = File.dirname __FILE__
        IO.read('%s/resources/%s' % [basedir, resource_name])
      end

    end
  end
end

Asciidoctor::Extensions.register do |document|
  document.block_macro Asciinurse::Chart::ChartBlockMacro
  document.docinfo_processor Asciinurse::Chart::ChartAssetsDocinfoProcessor
end
