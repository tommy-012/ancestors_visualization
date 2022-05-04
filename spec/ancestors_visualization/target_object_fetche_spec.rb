# frozen_string_literal: true

RSpec.describe AncestorsVisualization::TargetObjectFetcher do
  describe '#initialize' do
    context '存在しない Gem の場合' do
      subject(:new) { described_class.new('-') }

      specify do
        expect { new }.to raise_error(ArgumentError)
      end
    end
  end

  let(:fetcher) { described_class.new(gem_name) }
  let(:gem_name) { 'gem_name' }

  describe '#fetch' do
    subject(:fetch) { fetcher.fetch }

    let(:gem_load_part_path) { File.expand_path('../../fixtures/sample_gem_dir', __FILE__) }

    let(:target_objects) { [GemName, GemName::C1, GemName::Modules::M1_1, GemName::Modules::M1_2, GemName::Modules::M1_1_1, GemName::Modules::M1_1_2, GemName::Modules, GemName::C2, GemName::Modules::M2_1, GemName::Modules::M2_2] }

    before do
      allow_any_instance_of(described_class).to receive(:exec_command).with('bundle list --name-only').and_return("#{gem_name}\n")
      allow_any_instance_of(described_class).to receive(:exec_command).with("bundle info #{gem_name} --path").and_return(gem_load_part_path)
    end

    context '読み込みに成功した場合' do
      specify do

        expect(fetch).to match_array(target_objects)

        expect(fetcher.require_failed_files.count).to eq(0)
      end
    end

    context '読み込みに失敗した場合' do
      before do
        allow(fetcher).to receive(:require).and_raise(LoadError)
      end

      specify do
        # NOTE 先のテストで該当クラスがメモリ上に読み込まれているため、fetch の戻り値のテストはしない
        fetch

        # NOTE 名前空間分が余分なので減算する
        expect(fetcher.require_failed_files.count).to eq(target_objects.count - 1)
      end
    end
  end

  describe '#exec_command' do
    subject(:exec_command) { fetcher.send(:exec_command, command) }

    before do
      allow_any_instance_of(described_class).to receive(:exists_gem?).with(gem_name).and_return(true)
    end

    context 'コマンド実行に失敗した場合' do
      let(:command) { '-' }

      specify do
        expect { exec_command }.to raise_error(RuntimeError)
      end
    end
  end
end
