# frozen_string_literal: true

RSpec.describe AncestorsVisualization::GraphViz, require_sample_gem: true do
  let(:graph_viz) { described_class.new }

  let(:graph_viz_gem) { instance_double(::GraphViz) }

  before do
    allow(::GraphViz).to receive(:new).with(:G, described_class::GRAPHVIZ_SETTING).and_return(graph_viz_gem)
  end

  describe '#find_or_create_node' do
    subject(:find_or_create_node) { graph_viz.find_or_create_node(path_name) }
    let(:path_name) { 'GemName::Modules::M1_1' }

    let(:target_graph) { double(:target_graph) }
    let(:sub_graph) { double(:sub_graph) }

    before do
      allow(graph_viz_gem).to receive(:get_graph).with('cluster_GemName').and_return(sub_graph)
      allow(sub_graph).to receive(:get_graph).with('cluster_Modules').and_return(target_graph)

      allow(target_graph).to receive(:find_node).with(path_name).and_return(existing_node)
    end

    context '該当ノードが存在する場合' do
      let(:existing_node) { double(:existing_node) }

      specify do
        expect(graph_viz).to receive(:add_graph).with('GemName::Modules')

        expect(find_or_create_node).to eq(existing_node)
      end
    end

    context '該当ノードが存在しない場合' do
      let(:existing_node) { nil }
      let(:new_node) { double('new_node') }

      specify do
        expect(graph_viz).to receive(:add_graph).with('GemName::Modules')

        expect(target_graph).to receive(:add_nodes).with(path_name, label: 'M1_1', fillcolor: described_class::MODULE_NODE_COLOR, **described_class::NODE_SETTING).and_return(new_node)

        expect(find_or_create_node).to eq(new_node)
      end
    end
  end

  describe '#add_graph' do
    subject(:add_graph) { graph_viz.send(:add_graph, name_space) }

    context '名前空間が存在する場合' do
      let(:name_space) { 'GemName::Modules::Fuga' }

      let(:sub_graph_1) { double(:sub_graph_1) }
      let(:sub_graph_2) { double(:sub_graph_2) }

      before do
        allow(graph_viz_gem).to receive(:get_graph).with('cluster_GemName').and_return(sub_graph_1)
        allow(sub_graph_1).to receive(:get_graph).with('cluster_Modules').and_return(nil)
        allow(sub_graph_1).to receive(:add_graph).with('cluster_Modules', label: 'Modules', **described_class::GRAPH_SETTING).and_return(sub_graph_2)
        allow(sub_graph_2).to receive(:get_graph).with('cluster_Fuga').and_return(nil)
      end

      specify do
        expect(sub_graph_2).to receive(:add_graph).with('cluster_Fuga', label: 'Fuga', **described_class::GRAPH_SETTING)

        add_graph
      end
    end

    context '名前空間が存在しない場合' do
      let(:name_space) { nil }

      specify do
        expect(add_graph).to eq(nil)
      end
    end
  end

  describe '#link' do
    subject(:link) { graph_viz.link(source: src, destination: dst) }
    let(:src) { double('src', neighbors: neighbors) }
    let(:dst) { double('dst', id: 1) }

    context '該当リンクがある場合' do
      let(:neighbors) { [double('node', id: 1)] }

      specify do
        expect(graph_viz_gem).not_to receive(:add_edges)

        link
      end
    end

    context '該当リンクがない場合' do
      let(:neighbors) { [] }

      specify do
        expect(graph_viz_gem).to receive(:add_edges).with(src, dst, described_class::EDGE_SETTING)

        link
      end
    end
  end

  describe '#output' do
    subject(:output) { graph_viz.output(file_type: file_type, file_path: file_path) }
    let(:file_type) { :png }
    let(:file_path) { './file.png' }

    context '予期しない拡張子が指定されている場合' do
      let(:file_type) { :ng }

      specify do
        expect { output }.to raise_error(ArgumentError)
      end
    end

    specify do
      expect(graph_viz_gem).to receive(:output).with(file_type => file_path)

      output
    end
  end
end
