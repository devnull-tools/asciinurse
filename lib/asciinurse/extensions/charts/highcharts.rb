require 'asciidoctor/extensions'
require 'fileutils'
require 'tempfile'

module Asciinurse
  module Chart

    module ChartCreator

      def create_chart(parent, attrs, config)
        document = parent.document
        document.attributes['last-id'] ||= 0
        backend = document.attributes['backend']
        if backend == 'html5'
          html = create_from_json document, config
          create_pass_block parent, html, attrs, subs: nil
        else
          attrs['target'] = create_image document, config, attrs
          attrs['width'] ||= 480
          attrs['height'] ||= 250

          create_image_block parent, attrs
        end
      end

      def create_from_json(document, config)
        id = 'chart_%s' % (document.attributes['last-id'] += 1)
        %(
        <div id='#{id}'></div>
        <script type="text/javascript">
          $(function () {
              $('##{id}').highcharts(#{config});
          });
        </script>
        )
      end

      def create_from_csv(data, attrs)
        csv_data = CSVData::new :highcharts, attrs, data
        csv_data.to_chart_json
      end

      def create_image(document, config, attrs)
        converter = Asciinurse.find_resource :highcharts, :phantomjs, 'highcharts-convert.js'
        basedir = document.attributes['docdir']
        id = (document.attributes['last-id'] += 1)

        config_file = '%s/tmp/config-%d.json' % [basedir, id]
        image_file = '%s/tmp/chart-%d.png' % [basedir, id]

        IO.write config_file, config

        `phantomjs #{converter} -infile #{config_file} -outfile #{image_file} -scale 2.5`
        image_file
      end

    end

    class ChartBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      include ChartCreator

      use_dsl
      named :chart
      name_positional_attributes 'type', 'width', 'height'

      def process(parent, target, attrs)
        data_path = parent.normalize_asset_path(target, 'target')
        data = parent.read_asset(data_path, warn_on_failure: true, normalize: true)
        data = create_from_csv data, attrs if data_path.end_with? '.csv'
        create_chart parent, attrs, data
      end

    end

    class ChartBlockProcessor < Asciidoctor::Extensions::BlockProcessor
      include ChartCreator

      use_dsl
      named :chart
      on_context :literal
      name_positional_attributes 'type', 'width', 'height'
      parse_content_as :raw

      def process(parent, reader, attrs)
        data = create_from_csv reader.source, attrs
        create_chart parent, attrs, data
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
                #{Asciinurse.read_resource :highcharts, :javascripts, script}
              </script>
            )
          end).join $/
        end
      end

    end

  end
end
