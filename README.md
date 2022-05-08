# AncestorsVisualization
## 概要
Gem のクラス継承・モジュール利用を可視化する Gem です

作ったきっかけとしては、Gem の実装を読む時に全体感を把握したいなと思うことがあったので

例えば、以下のクラス・モジュール（Gem 名は GemName を想定）があったとして

```ruby
# sample_gem_dir/lib/gem_name/c1.rb
module GemName
  class C1 < C2
    include Modules::M1_1
    extend Modules::M1_2
  end
end

# sample_gem_dir/lib/gem_name/modules/m1_1.rb
module GemName
  module Modules
    module M1_1
      include M1_1_1
      extend M1_1_2

      def m1_1
      end
    end
  end
end

# sample_gem_dir/lib/gem_name/modules/m1_2.rb
module GemName
  module Modules
    module M1_2
      def self.m1_2
      end
    end
  end
end

# sample_gem_dir/lib/gem_name/modules/m1_1_1.rb
module GemName
  module Modules
    module M1_1_1
      def m1_1_1
      end
    end
  end
end

# sample_gem_dir/lib/gem_name/modules/m1_1_2.rb
module GemName
  module Modules
    module M1_1_2
      def self.m1_1_2
      end
    end
  end
end

# sample_gem_dir/lib/gem_name/c2.rb
module GemName
  class C2
    include Modules::M2_1
    extend Modules::M2_2
  end
end

# sample_gem_dir/lib/gem_name/modules/m2_1.rb
module GemName
  module Modules
    module M2_1
      def m2_1
      end
    end
  end
end

# sample_gem_dir/lib/gem_name/modules/m2_2.rb
module GemName
  module Modules
    module M2_2
      def self.m2_2
      end
    end
  end
end
```

本 Gem を使うと、↓ の画像を生成します

![test](https://user-images.githubusercontent.com/46615665/166624534-6cd57cc6-e7cd-455b-9d9c-3af002f5435b.png)

- 右上に表示されている括りが、名前空間に対応
- 各ノードは、クラス・モジュールに対応
    - 水色がクラス
    - オレンジ色がモジュール
- 矢印は、継承・インクルードに対応

### ⚠️ 注意点

- 描画内容は正確でないことがあります
    - まず前提として、描画対象となるクラス・モジュールは、該当 Gem 名から判定した名前空間配下のみにしてます
        - 特に制限せずに描画した時に、ノードが多過ぎて見にくかったので
        - なので、[標準クラス](https://docs.ruby-lang.org/ja/latest/library/_builtin.html)は描画されないです
    - 実装としては存在するのに、描画されてないクラスがあるかもしれないです
        - 実装を見てもらうとわかるのですが、描画対象を解析する際に、対象の Gem の作りにいくつか前提を置いています
        - なので、それが守られていないと、描画に失敗します（[例](https://github.com/tommy-012/ancestors_visualization#%E5%AE%9F%E8%A1%8C%E4%BE%8B-2)）
- あくまでコードリーディングする際の参考として使ってください

## インストール方法

以下を Gemfile に追記して `$ bundle install`

```ruby
gem 'ancestors_visualization'
```

Budler を使わない場合は

```sh
$ gem install ancestors_visualization
```

## 使い方

実行フォーマットは以下

```sh
$ bundle exec ancestors_visualization --gem [Gem 名] --output_path [描画ファイルの出力先]
```

- gem は必須
- output_path は必要であれば
    - デフォルトは、`[Gem 名]_ancestors_[年月日時分秒].png`
    - 例えば、twitter_ancestors_20220504141646.png

### 実行例 1
例えば、[Twitter Gem](https://github.com/sferik/twitter) に対して実行する場合

```sh
$ bundle exec ancestors_visualization --gem twitter
```

![twitter_ancestors_20220504141646](https://user-images.githubusercontent.com/46615665/166626477-26a20225-c7ed-487a-be7c-0a7a2def97aa.png)

### 実行例 2
例えば、[Rspec](https://github.com/rspec/rspec-core) に対して実行する場合

該当 Gem の lib 配下のクラス・モジュールを描画対象にしているので、依存先の Gem が本体みたいなケースは、意図しない描画結果になります

↓ で描画結果を表示しているのですが、何も表示されていないのはそういうことです

![rspec_ancestors_20220504174723](https://user-images.githubusercontent.com/46615665/166649622-61bc7626-0daa-4c22-9408-94a6375b3e0a.png)

## ライセンス

[MIT License](https://opensource.org/licenses/MIT)
