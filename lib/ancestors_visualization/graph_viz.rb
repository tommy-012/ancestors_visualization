# frozen_string_literal: true

require 'ruby-graphviz'

module AncestorsVisualization
  class GraphViz
    GRAPHVIZ_SETTING = {
      use:         :dot,
      type:        :digraph,
      rankdir:     :LR,
      ranksep:     0.5,
      nodesep:     0.5,
      pad:         "0.4,0.4",
      margin:      "0,0",
      concentrate: true,
      labelloc:    :t,
      fontsize:    13,
      splines:     'spline', # NOTE https://graphviz.org/docs/attrs/splines/
    }

    GRAPH_SETTING = {
      labelloc:  "t",
      labeljust: "l",
      fillcolor: "#888888"
    }

    EDGE_SETTING = {
      color: '#444444'
    }

    NODE_SETTING = {
      style:    "filled",
      fontname: "Helvetica Neue"
    }

    OTHER_NODE_COLOR = '#f2f2f2'
    CLASS_NODE_COLOR = '#c4ddec'
    MODULE_NODE_COLOR = '#ecd3c4'

    EXPECTED_FILE_TYPE = [
      :pdf,
      :png,
      :jpg,
      :svg
    ]

    NAME_SPACE_DELIMITER = '::'

    def find_or_create_node(klass_or_module_path_name)
      name_space = klass_or_module_path_name.deconstantize

      add_graph(name_space)

      target_graph = name_space.split(NAME_SPACE_DELIMITER).inject(graph_viz) {|graph, name| graph.get_graph(cluster_name(name)) }

      if (existing_node = target_graph.find_node(klass_or_module_path_name)).present?
        existing_node
      else
        klass_or_module_name = klass_or_module_path_name.split(NAME_SPACE_DELIMITER).last

        target_graph.add_nodes(klass_or_module_path_name, label: klass_or_module_name, fillcolor: node_color(klass_or_module_path_name), **NODE_SETTING)
      end
    end

    def link(source:, destination:)
      return if source.neighbors.present? && source.neighbors.map(&:id).include?(destination.id)

      graph_viz.add_edges(source, destination, EDGE_SETTING)
    end

    def output(file_type:, file_path:)
      raise ArgumentError, "file_type is #{file_type}. file_type must be #{EXPECTED_FILE_TYPE.join(',')}." if EXPECTED_FILE_TYPE.exclude?(file_type)

      graph_viz.output(file_type => file_path)
    end

    private

    def add_graph(name_space)
      return if name_space.blank?

      parent_graph = graph_viz

      name_space.split(NAME_SPACE_DELIMITER).each do |part_name_space|
        if existing_graph = parent_graph.get_graph(cluster_name(part_name_space))
          parent_graph = existing_graph

          next
        end

        parent_graph = parent_graph.add_graph(cluster_name(part_name_space), label: part_name_space, **GRAPH_SETTING)
      end
    end

    def cluster_name(name)
      "cluster_#{name}"
    end

    def node_color(object)
      case object.constantize.class.to_s
      when 'Class'
        CLASS_NODE_COLOR
      when 'Module'
        MODULE_NODE_COLOR
      else
        OTHER_NODE_COLOR
      end
    rescue
      OTHER_NODE_COLOR
    end

    def graph_viz
     @graph_viz ||= ::GraphViz.new(:G, GRAPHVIZ_SETTING)
    end
  end
end
