# frozen_string_literal: true

RSpec.describe AncestorsVisualization::CLI, type: :model, stop_the_time: true do
  let(:cli) { described_class.new(gem_name: gem_name, output_path: output_path) }
  let(:gem_name) { 'gem_name' }
  let(:output_path) { nil }

  describe '#execute' do
    subject(:execute) { cli.execute }

    let(:target_object_fetcher) { instance_double('TargetObjectFetcher') }
    let(:target_objects) { [Object] }
    let(:diagram_creater) { instance_double('DiagramCreater') }
    let(:default_output_path) { "#{Dir.pwd}/#{gem_name}_ancestors_#{Time.current.strftime("%Y%m%d%H%M%S")}.png" }
    let(:not_require_file_message) { '以下のファイルは読み込めなかったため、描画結果に反映されていません。' }

    describe '正常系' do
      before do
        allow(AncestorsVisualization::TargetObjectFetcher).to receive(:new).with(gem_name).and_return(target_object_fetcher)
        allow(target_object_fetcher).to receive(:fetch).and_return(target_objects)
        allow(target_object_fetcher).to receive(:require_failed_files).and_return(require_failed_files)
        allow(AncestorsVisualization::DiagramCreater).to receive(:new).with(target_objects: target_objects, output_path: default_output_path).and_return(diagram_creater)
      end

      context '全ファイルを読み込めた場合' do
        let(:require_failed_files) { [] }

        specify do
          expect(diagram_creater).to receive(:create)
          expect(cli).not_to receive(:puts).with(not_require_file_message)

          execute
        end
      end

      context '一部ファイルが読み込めなかった場合' do
        let(:require_failed_files) { [file] }
        let(:file) { 'dir/file.rb' }

        specify do
          expect(diagram_creater).to receive(:create)
          expect(cli).to receive(:puts).with('描画結果を以下に出力しました。')
          expect(cli).to receive(:puts).with(default_output_path)
          expect(cli).to receive(:puts).with(not_require_file_message)
          expect(cli).to receive(:puts).with('```').exactly(4).times
          expect(cli).to receive(:puts).with("- #{file}")

          execute
        end
      end
    end

    describe '異常系' do
      let(:error_message) { 'error_message' }

      context 'エラーが発生した場合' do
        before do
          allow(cli).to receive(:fetch_target_objects).and_raise(StandardError.new(error_message))
        end

        specify do
          expect($stderr).to receive(:puts).with("描画に失敗しました。\nエラー内容: #{error_message}")

          execute
        end
      end
    end
  end
end
