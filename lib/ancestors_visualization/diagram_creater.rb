# frozen_string_literal: true

require 'ancestors_visualization/graph_viz'

module AncestorsVisualization
  class DiagramCreater
    def initialize(target_objects:, output_path:)
      raise ArgumentError, "'#{File.dirname(output_path)}' does not exist." unless Dir.exist?(File.dirname(output_path))

      @target_objects = target_objects
      @output_path = output_path
    end

    def create
      # NOTE 名前空間の描画を減らすため、起点オブジェクトはクラスに限定する
      target_classes.each do |klass|
        draw_diagram(klass)
      end

      output_diagram
    end

    private

    attr_reader :target_objects, :output_path

    def target_classes
      @target_classes ||= target_objects.select {|o| o.instance_of?(Class) }
    end

    def draw_diagram(object)
      # NOTE 対象クラスのinclude先のモジュールは描画したい
      object_with_ancestor_modules(object).each do |object|
        relation = ObjectRelation.new(object, target_objects)

        return if relation.source.blank?

        src = graph_viz.find_or_create_node(relation.source.to_s)

        relation.destinations.each do |dst|
          graph_viz.link(
            source: src,
            destination: graph_viz.find_or_create_node(dst.to_s),
          )
        end

        relation.extend_destinations.each do |dst|
          graph_viz.link(
            source: src,
            destination: graph_viz.find_or_create_node(dst.to_s),
          )
        end
      end
    end

    def object_with_ancestor_modules(object)
      [object].concat(object.ancestors.select {|o| o.instance_of?(Module) })
    end

    def output_diagram
      file_type = File.extname(output_path).delete('.').to_sym

      graph_viz.output(file_type: file_type, file_path: output_path)
    end

    def graph_viz
      @graph_viz ||= AncestorsVisualization::GraphViz.new
    end

    class ObjectRelation
      def initialize(object, target_objects)
        @object = object
        @target_objects = target_objects
      end

      def source
        return nil unless under_target_namespaces?(object)

        @source ||= object
      end

      def destinations
        @destinations ||= begin
          dsts = ancestors_without_self(object)

          ancestors_without_self(object).each do |klass|
            dsts -= ancestors_without_self(klass)
          end

          dsts.select {|o| under_target_namespaces?(o) }
        end
      end

      def extend_destinations
        @extend_destinations ||= begin
          dsts = extended_modules(object)

          ancestors_without_self(object).each do |klass|
            dsts -= extended_modules(klass)
          end

          dsts.select {|o| under_target_namespaces?(o) }
        end
      end

      private

      attr_reader :object, :target_objects

      def under_target_namespaces?(object)
        target_namespaces.include?(object.to_s.split('::').first)
      end

      def target_namespaces
        @target_namespaces ||= target_objects.map{|o| o.to_s.split('::').first }.compact_blank.uniq
      end

      def ancestors_without_self(klass)
        klass.ancestors - [klass]
      end

      def extended_modules(object)
        target_modules.select {|m| extend?(object, m) }
      end

      def target_modules
        @target_modules ||= target_objects.select {|o| o.instance_of?(Module) }
      end

      def extend?(src, dst)
        src.singleton_class.include?(dst)
      end
    end
  end
end
