# frozen_string_literal: true

module AncestorsVisualization
  class TargetObjectFetcher
    attr_accessor :require_failed_files

    def initialize(gem_name)
      raise ArgumentError, "#{gem_name} is not found." unless exists_gem?(gem_name)

      @gem_name = gem_name
      @require_failed_files = Set.new
    end

    def fetch
      require_gem

      fetch_gem_object
    end

    private

    attr_reader :gem_name

    def exists_gem?(gem_name)
      result = exec_command('bundle list --name-only')

      result.split("\n").include?(gem_name)
    end

    def exec_command(command)
      result = `#{command}`

      raise RuntimeError, "`#{command}` is failed." unless $?.success?

      result
    end

    def require_gem
      Dir.glob("#{gem_load_path}/**/*.rb").each do |file|
        begin
          require file
        rescue Exception
          # NOTE オプション扱いで別 Gem に依存しているケース等、読み込めないことがある
          require_failed_files << file
        end
      end
    end

    def gem_load_path
      @gem_load_path = begin
        result = exec_command("bundle info #{gem_name} --path")

        # TODO 対象 Gem の設定を参照できればそう修正する
        load_dir = 'lib'

        "#{result.chomp}/#{load_dir}"
      end
    end

    def fetch_gem_object
      ObjectSpace.each_object(Module).select do |object|
        fetch_target?(object)
      end
    end

    def fetch_target?(object)
      top_namespace_name = object.to_s.split('::').first.underscore

      # NOTE lib 直下のファイル・ディレクトリ名から名前空間を推定しているため、名前空間が正しい保証はない
      file_and_dir_names.any? {|n| n == top_namespace_name }
    rescue
      # NOTE object.to_s が未定義でエラーになることがある
      false
    end

    def file_and_dir_names
      @file_and_dir_names ||= Dir.glob("#{gem_load_path}/*").map {|path| File.basename(path, '.*') }.uniq
    end
  end
end
