# bitclust 作業メモ

## rbs 導入したい 15日目

### `|| raise` 対応

- 久しぶりに作業しようとすると型エラーが意図的に無視しているものかどうか区別しにくくて、いつまでも進まないので `|| raise` をつけていくことにした。
- `# :on_event --> "event"` のような `# :` で始まるコメントが型の何かに誤解されることがあったはずなので、 `## :` に置き換えておくことにした。
- `MethodSpec.new(*methodid2specparts(@id))` などの `*` での引数展開のサポートが弱いようなので、 `c, t, m, lib = methodid2specparts(@id)` のように一度変数で受けてから `MethodSpec.new(c, t, m, lib)` のように個別に渡すようにした。
- `return m.captures` は以下のように個別変数にして `|| raise` をつけたり `_ =` 経由で正規表現でチェック済みの型をつけたりした。

```ruby
        cname = m[1] || raise
        # @type var tmark: NameUtils::typemark
        tmark = _ = m[2] || raise
        mname = m[3] || raise
        return [cname, tmark, mname]
```

- `typename?` などは緩く受けて `NAME_TO_MARK.key?(_ = n)` のように `_ =` で `key?` の型エラーを無視するようにした。
- `typename2mark` などは例外になるだけなので、例外になるようなものはあらかじめ渡しそうになったらわかるように、型を厳しくした。
- `String#[]` に `|| raise` をつける必要があるのが不便。
- `$1` や `Array#first` などに `|| raise` が必要なのはしかたないかなと思ってしまう。
- チェック済のはずなので、 `@context.type = _ = "#{t}_method".intern` で型エラーを無視するようにしたが、大丈夫なのかちょっと不安がある。
- `Pathname(ENV['HOME'])` のような環境変数を参照しているところは `Pathname(ENV.fetch('HOME'))` にした。
- `cname, tmark, mname = *split_method_spec(spec)` の `*` を削って `cname, tmark, mname = split_method_spec(spec)` にする必要があるのは steep に対応してほしかったが、対処済みなのか意図的に無視しているのかわかりにくいので、削った。

### バグの可能性調査

- `BitClust::ClassEntry#singleton_method?` の `singleton_methods(false)` は `def singleton_methods(level = 0)` が呼ばれるなら、引数が `Integer` ではないので、バグってそうだったので、使われているコードかどうか確認する必要がありそう。
- バグとしては `def entries(level = 0)` の `ancestors[1..level]` で `1..false` になって `bad value for range (ArgumentError)` になるはず。
- ざっとみた感じ `singleton_method?(name, true)` でしか呼ばれていなくて、使われてなさそうでバグを踏んでなさそうに見えた。
- `instance_method?` も同様。
- `constant?` は `ancestors().any? {|c| c.constant?(name, false) }` で `inherit` が `false` の時の処理も呼ばれてそうだった。

## rbs 導入したい 16日目

- `lib/bitclust/searcher.rb` で使われていた `nkf` と `yaml` を `rbs_collection.yaml` に追加して `rbs collection update` で反映した。
- `lib/bitclust/screen.rb` で `to_json` が使われていたので `json` も追加した。

## rbs 導入したい 17日目

- `libraryentry.rb` に型付けをしていた。
- `error_classes` のようにキャッシュ用の同名のインスタンス変数があるメソッドは `attr_reader` で省略した型定義にした。
- `all_classes` のようなインスタンス変数だけ `nil` になる可能性のあるものは省略できなかった。
- `lib.is_sublibrary = true` があったので、 `property` は `attr_accessor` にする必要があるとわかった。
- VSCode で使われるだけなら `alias` などの自動生成は `sig/prototype/**/*.rbs` に残しておいた方が自動生成そのままだとわかりやすくていいかと思っていたが、ファイルをジャンプして型定義を見るようになると、1ファイルにまとまっていた方が便利そうなので、 `alias` なども `sig/hand-written/**/*.rbs` に移動してみたが、 `private` や `public` などの行は残ってしまった。
- `doctree` から HTML の生成を確認したら、正常に `nil` の可能性があるところまで `|| raise` をつけてしまっていたので修正した。
- 生成された HTML は `git diff --no-index /tmp/html /tmp/html.a` で差分がないことが確認できた。
