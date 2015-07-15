require 'json'
require 'csv'
require 'erb'

module Asciinurse
  module Chart

    Series = Struct::new :name, :data

    class CSVData
      def initialize(attrs, csv_content)
        @title = attrs['title']
        @type = attrs['type']
        @csv = CSV.parse(csv_content, :converters => :all)
        @has_id = @csv.first.first == '$ID'
        parse_data
      end

      def to_chart_json
        ERB.new(get_template).result binding
      end

      private

      def get_template(default = 'generic.json.erb')
        basedir = File.dirname __FILE__
        begin
          IO.read('%s/templates/%s.json.erb' % [basedir, @type])
        rescue
          IO.read('%s/templates/%s' % [basedir, default])
        end
      end

      def parse_data
        @series = @csv.collect do |row|
          if @has_id
            Series::new row.first, row[1..-1]
          else
            Series::new nil, row
          end
        end
      end

    end
  end
end
