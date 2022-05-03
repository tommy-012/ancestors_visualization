# frozen_string_literal: true

require 'ancestors_visualization/target_object_fetcher'
require 'ancestors_visualization/diagram_creater'

require 'active_support/all'

module AncestorsVisualization
  class CLI
    def initialize(gem_name:, output_path: nil)
      @gem_name = gem_name
      @output_path = output_path
    end

    def execute
      create_diagram

      print_require_failed_files
    rescue Exception => e
      $stderr.puts("描画に失敗しました。\nエラー内容: #{e.message}")
    end

    private

    attr_reader :gem_name, :output_path

    def create_diagram
      DiagramCreater.new(
        target_objects: fetch_target_objects,
        output_path: output_path || default_output_path
      ).create
    end

    def fetch_target_objects
      target_object_fetcher.fetch
    end

    def target_object_fetcher
      @target_object_fetcher ||= TargetObjectFetcher.new(gem_name)
    end

    def default_output_path
      "#{Dir.pwd}/output/#{gem_name}_ancestors_#{Time.current.strftime("%Y%m%d%H%M%S")}.png"
    end

    def print_require_failed_files
      return if target_object_fetcher.require_failed_files.blank?

      puts '以下のファイルは require できなかったため、図に反映されていません。'
      puts '```'
      target_object_fetcher.require_failed_files.each do |f|
        puts "- #{f}"
      end
      puts '```'

      nil
    end
  end
end
