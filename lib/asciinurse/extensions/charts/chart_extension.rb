require 'asciidoctor/extensions'
require 'fileutils'

require_relative 'chart_data'

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
        document.attributes['last-id'] ||= 0
        id = 'chart_%s' % (document.attributes['last-id'] += 1)

        data = parent.read_asset(data_path, warn_on_failure: true, normalize: true)
        if backend == 'pdf'
          raise 'Sorry!'
        elsif backend == 'html5'
          result = if data_path.end_with? '.csv'
                     create_from_csv id, data, attrs
                   else
                     create_from_json id, data
                   end
          create_pass_block parent, result, attrs, subs: nil
        end
      end

      def create_from_json(id, data)
        %(
        <div id='#{id}'></div>
        <script type="text/javascript">
          $(function () {
              $('##{id}').highcharts(#{data});
          });
        </script>
        )
      end

      def create_from_csv(id, data, attrs)
        csv_data = CSVData::new attrs, data
        create_from_json id, csv_data.to_chart_json
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
                #{Asciinurse.read_resource :javascript, script}
              </script>
            )
          end).join $/
        end
      end

    end
  end
end

Asciidoctor::Extensions.register do |document|
  document.block_macro Asciinurse::Chart::ChartBlockMacro
  document.docinfo_processor Asciinurse::Chart::ChartAssetsDocinfoProcessor
end
