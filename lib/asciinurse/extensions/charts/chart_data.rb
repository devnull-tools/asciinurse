require 'json'
require 'csv'
require 'erb'

module Asciinurse
  module Chart

    class CSVData
      def initialize(engine, attrs, csv_content)
        @engine = engine
        @title = attrs['title']
        @type = attrs['type']
        @csv = CSV.parse(csv_content, :converters => :all)
        @has_id = @csv.first.first == '$ID'
        @header = @has_id ? @csv.first[1..-1] : @csv.first
        parse_data
      end

      def to_chart_json
        ERB.new(get_template).result binding
      end

      private

      def get_template(default = 'generic.json.erb')
        template = Asciinurse.find_resource "#{@engine}/templates/charts/#{@type}.json.erb"
        template ||= Asciinurse.find_resource "#{@engine}/templates/charts/#{default}"
        IO.read template
      end

      def parse_data
        @series = @csv[1..-1].collect do |row|
          if @has_id
            {
                name: row.first,
                data: row[1..-1]
            }
          else
            {
                data: row
            }
          end
        end
      end

    end
  end
end
