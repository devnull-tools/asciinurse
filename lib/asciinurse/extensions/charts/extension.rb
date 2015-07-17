require 'asciidoctor/extensions'

require_relative 'chart_data'

module Asciinurse
  module Chart
    module ChartCreator

      def get_engine(doc)
        doc.attributes['charts'] || Asciinurse.config('charts.default')
      end

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
        engine = get_engine document
        template = Asciinurse.read_resource "#{engine}/templates/chart.html.erb"
        ERB.new(template).result binding
      end

      def create_from_csv(engine, data, attrs)
        csv_data = CSVData::new engine, attrs, data
        csv_data.to_chart_json
      end

      def create_image(document, config, attrs)
        engine = get_engine document
        converter_file = Asciinurse.config "charts.#{engine}.convert.js"
        tmpdir = Asciinurse.tmp_dir document
        id = (document.attributes['last-id'] += 1)

        config_file = "#{tmpdir}/config-#{id}.json"
        image_file = "#{tmpdir}/chart-#{id}.png"

        IO.write config_file, config

        command = Asciinurse.config "charts.#{engine}.convert.command"
        converter = Asciinurse.find_resource "#{engine}/#{command.split.first}/#{converter_file}"
        command = command % [converter, config_file, image_file]

        `#{command}`
        image_file
      end

    end

    class ChartBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      include ChartCreator

      use_dsl
      named :chart
      name_positional_attributes 'type', 'width', 'height'

      def process(parent, target, attrs)
        engine = get_engine parent.document
        data_path = parent.normalize_asset_path(target, 'target')
        data = parent.read_asset(data_path, warn_on_failure: true, normalize: true)
        data = create_from_csv engine, data, attrs if data_path.end_with? '.csv'
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
        engine = get_engine parent.document
        data = create_from_csv engine, reader.source, attrs
        create_chart parent, attrs, data
      end
    end

    class ChartAssetsDocinfoProcessor < Asciidoctor::Extensions::DocinfoProcessor
      include ChartCreator

      use_dsl
      at_location :header

      def process(doc)
        engine = get_engine(doc)
        doc.attributes['charts'] = engine
        scripts = Asciinurse.config "charts.#{engine}.include"
        if doc.attributes['backend'] == 'html5'
          (scripts.collect do |script|
            %(<script type="text/javascript">
                #{Asciinurse.read_resource "#{engine}/javascripts/#{script}"}
              </script>)
          end).join $/
        end
      end

    end
  end
end

Asciidoctor::Extensions.register do |registry|
  registry.block_macro Asciinurse::Chart::ChartBlockMacro
  registry.block Asciinurse::Chart::ChartBlockProcessor
  registry.docinfo_processor Asciinurse::Chart::ChartAssetsDocinfoProcessor
end
