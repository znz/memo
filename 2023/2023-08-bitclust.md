# bitclust 作業メモ

## rbs 導入したい 15日目

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
