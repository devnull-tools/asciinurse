require 'json'
require 'csv'
require 'erb'

module Asciinurse
  module Chart

    class CSVData
      def initialize(engine, attrs, csv_content)
        defaults = Asciinurse.config "charts.#{engine}.defaults"
        options = defaults.merge attrs if defaults
        options ||= attrs
        @engine = engine
        @title = options['title']
        @type = options['type']
        @width = options['width']
        @height = options['height']
        @csv = CSV.parse(csv_content, :converters => :all)
        parse_data
      end

      def to_chart_json
        ERB.new(get_template).result binding
      end

      private

      def get_template(default = 'generic.json.erb')
        template = Asciinurse.find_resource "#{@engine}/templates/charts/#{@type}.json.erb"
        template ||= Asciinurse.find_resource "#{@engine}/templates/charts/#{default}"
        raise "Template not found for #{@engine}:#{@type}" unless template
        IO.read template
      end

      def parse_data
        @target = @csv[0][0]
        @elements = @csv.size - 1
        @series = []
        @header = []
        @elements.times do |n|
          @header << @csv[n + 1].first
        end
        (@csv[0].size - 1).times do |n|
          row = {
              name: @csv[0][n + 1],
              data: []
          }
          @elements.times do |el|
            row[:data] << @csv[el + 1][n + 1]
          end
          @series << row
        end
      end

    end
  end
end
