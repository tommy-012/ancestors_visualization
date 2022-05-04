# frozen_string_literal: true

RSpec.describe AncestorsVisualization::DiagramCreater, require_sample_gem: true do
  let(:creater) { described_class.new(target_objects: target_objects, output_path: output_path) }
  let(:target_objects) {
    ObjectSpace.each_object(Module).select do |object|
      object.to_s.split('::').first == 'GemName'
    rescue
      # NOTE .to_s が未定義でエラーになることがある
    end
  }
  let(:output_path) { 'output.png' }

  describe '#initialize' do
    context '出力先のディレクトリが存在しない場合' do
      subject(:new) { creater }
      let(:output_path) { '-/test' }

      specify do
        expect { new }.to raise_error(ArgumentError)
      end
    end
  end

  let(:graph_viz) { instance_double(AncestorsVisualization::GraphViz) }

  before do
    allow(AncestorsVisualization::GraphViz).to receive(:new).and_return(graph_viz)
  end

  describe '#create' do
    subject(:create) { creater.create }

    specify do
      expect(creater).to receive(:draw_diagram).with(GemName::C1).once
      expect(creater).to receive(:draw_diagram).with(GemName::C2).once

      expect(graph_viz).to receive(:output).with(file_type: :png, file_path: output_path)

      create
    end
  end

  describe '#draw_diagram' do
    subject(:draw_diagram) { creater.send(:draw_diagram, GemName::C1) }
    let(:c1) { double('c1_node') }
    let(:m1_1) { double('m1_1_node') }
    let(:m1_1_1) { double('m1_1_1_node') }
    let(:m1_1_2) { double('m1_1_2_node') }
    let(:m1_2) { double('m1_2_node') }
    let(:c2) { double('c2_node') }
    let(:m2_1) { double('m2_1_node') }
    let(:m2_2) { double('m2_2_node') }

    before do
      allow(graph_viz).to receive(:find_or_create_node).with(GemName::C1.to_s).and_return(c1)
      allow(graph_viz).to receive(:find_or_create_node).with(GemName::Modules::M1_1.to_s).and_return(m1_1)
      allow(graph_viz).to receive(:find_or_create_node).with(GemName::Modules::M1_2.to_s).and_return(m1_2)

      allow(graph_viz).to receive(:find_or_create_node).with(GemName::C2.to_s).and_return(c2)
      allow(graph_viz).to receive(:find_or_create_node).with(GemName::Modules::M2_1.to_s).and_return(m2_1)
      allow(graph_viz).to receive(:find_or_create_node).with(GemName::Modules::M2_2.to_s).and_return(m2_2)

      allow(graph_viz).to receive(:find_or_create_node).with(GemName::Modules::M1_1_1.to_s).and_return(m1_1_1)
      allow(graph_viz).to receive(:find_or_create_node).with(GemName::Modules::M1_1_2.to_s).and_return(m1_1_2)
    end

    specify do
      expect(graph_viz).to receive(:link).with(source: c1, destination: m1_1)
      expect(graph_viz).to receive(:link).with(source: c1, destination: m1_2)
      expect(graph_viz).to receive(:link).with(source: c1, destination: c2)

      expect(graph_viz).to receive(:link).with(source: m1_1, destination: m1_1_1)
      expect(graph_viz).to receive(:link).with(source: m1_1, destination: m1_1_2)

      expect(graph_viz).not_to receive(:link).with(source: c1, destination: m2_1)
      expect(graph_viz).not_to receive(:link).with(source: c1, destination: m2_2)

      draw_diagram
    end
  end
end
