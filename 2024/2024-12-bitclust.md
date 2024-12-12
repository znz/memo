# bitclust 作業メモ

## setup_command.rb

rbs の方は特に悩むところはなかった。

setup_command.rb の方は

```ruby
            if /\Ay\z/i =~ $stdin.gets.chomp
```

を

```ruby
            if /\Ay\z/i =~ $stdin.gets&.chomp
```

にした。

型をつけると `to_yaml` が

```text
Type `::Hash[::Symbol, untyped]` does not have method `to_yaml`(Ruby::NoMethod)
```

になってしまった。

## update_command.rb

rbs の方は悩まなかったが、
`--capi` オプションがあるときだけ `BitClust::FunctionDatabase` になって、
それ以外は `BitClust::MethodDatabase` になる `@db` で `MethodDatabase` にしかないメソッドの呼び出しが型エラーになるので、
ローカル変数に入れて型ガードの `or raise` を追加した。

```diff
--- a/lib/bitclust/subcommands/update_command.rb
+++ b/lib/bitclust/subcommands/update_command.rb
@@ -37,7 +37,9 @@ module BitClust
         super
         @db.transaction {
           if @root
-            @db.update_by_stdlibtree @root
+            db = @db
+            db.is_a?(MethodDatabase) or raise
+            db.update_by_stdlibtree(@root || raise)
           end
           argv.each do |path|
             @db.update_by_file path, @library || guess_library_name(path)
```

## entry.rbs

途中で方針を変更して prototype に生成されるものそのままでも hand-written に書く、ということにしたので、
prototype で生成されてそのまま使えるものはそのまま使うという方針の頃に残していた型定義を hand-written に移動したが、
`self.@slots` だけ残ってしまった。
`self.@slots: Array[Property]` と書いているが、 VSCode 上で確認しても型定義がみつからない、と出てくるので、
認識されてなさそう。

```rbs
module BitClust
  # Ancestor of entry classes.
  class Entry
    self.@slots: untyped
  end
end
```

## server.rbs

自動生成のまま使う部分が prototype に残っていたので hand-written に移動した。

## ancestors_command.rbs

`rb` ファイルの方に `|| raise` などをつけつつ `rbs` ファイルを更新した。

## query_command.rbs

`initialize` と `exec` だけで、型は `subcommands` の中で一番簡単だった。

## property_command.rbs

`initialize` と `parse` と `exec` だけで、型は簡単だった。

## epub_command.rbs

`BitClust::Generators::EPUB` に渡すための設定値のインスタンス変数の確認だけだった。

## init_command.rbs

型は `STANDARD_PROPERTIES` の要素をリテラルから `String` に緩めただけ。

`rb` ファイルの方で `nil` チェックを追加した。

argv の形式チェックはあった方が親切っぽいので、エラーメッセージをちゃんと書いた。

```ruby
          argv.each do |kv|
            k, v = kv.split('=', 2)
            if k.nil? || v.nil?
              raise "argument must be KEY=VALUE, but #{kv.inspect}"
            end
            db.propset k, v
          end
```

## lookup_command.rbs

このあたりは Symbol にしてもいいかもしれないと思いつつ、リテラルのユニオンにした。

```rbs
      @format: (:text | :html)

      @type: (nil | :library | :class | :method | :function)
```

`nil` を想定していないメソッドの引数はそういう型にして、呼び出し側で以下のように `@ivar || raise` にした。

```ruby
        entry = fetch_entry(@db, @type, @key || raise)
        puts fill_template(get_template(@type || raise, @format || raise), entry)
```

## progress_bar.rbs

型としては fallback 用のクラスと同じということにした。

```rbs
class ProgressBar = ::BitClust::SilentProgressBar
```

## methoddatabase.rbs, parseutils.rbs, functionentry.rbs, methodentry.rbs

prototype に残っていた型を hand-written にマージした。

## nameutils.rbs

prototype に残っていた型を hand-written にマージした。

以下のブロックの型が (`*` での展開の問題で) うまくかけないため、 `@@split_method_id` の値の型は `untyped` にした。

```ruby
    def split_method_id(id)
      @@split_method_id[id] ||= begin
        c, rest = id.split("/")
        [c, *rest&.split(%r<[/\.]>, 3)]
      end
    end
```

## refsdatabase.rbs

`rb` ファイルの方にも `# @type var src: _ToStr` などを入れていった。

`===[a:inplace] インプレースエディットモード` のようなリンクで飛ぶ先を持っているデータベースだった。
(リンクする側は `[[ref:c:ARGF#inplace]]` のように書くようになっている。)

## rrdparser.rbs

prototype に残っていた型を hand-written にマージした。

## runner.rbs

`Subcommand` の `exec` の `options` は `:capi => bool` が入っていたので、
`Hash[Symbol, String?] options` から `Hash[Symbol, untyped] options` に変更した。

## rrdparser.rb

この行のエラーを考えていて、 `@kind` の型を `Symbol?` から `(:defined| :added | :redefined)` に修正すると、
`MethodEntry` の `attr_accessor kind` の型や `property :kind` のコメントに `:undefined` が抜けているというバグがみつかった。

```ruby
          m.kind            = chunk.source.match?(/^@undef$/) ? :undefined : @kind
```

## ancestors_command.rb

`[]` を代入していて `Array[untyped]` になっていたところにコメントで型をつけた。

## chm_command.rb

`methods = {}` の型をちゃんとつけて、 `create_html_file` の型を仮のままにしていたのを修正した。

## libraryentry.rb lineinput.rb messagecatalog.rb nameutils.rb rrdparser.rb

型のコメントをつけた。

## rrdparser.rbs

https://github.com/znz/bitclust/blob/7ca946fcc9a0768fa20050e270be642053486066/lib/bitclust/rrdparser.rb#L459
の型エラーが直らないので、 ruby-jp#types で質問。

````markdown
https://github.com/znz/bitclust/blob/7ca946fcc9a0768fa20050e270be642053486066/lib/bitclust/rrdparser.rb#L459 の
```
          m.visibility      = @visibility || :public
```
という行で
m.visibility は
```
attr_accessor visibility: (:public | :private | :protected)
```
で
@visibility は (代入が正規表現から切り出して intern している関係で)
```
attr_reader visibility: (:public | :private | :protected)?
attr_writer visibility: Symbol?
```
としてみているのですが、 `||` の右辺の `:public` の型が `:public` にならずに `::Symbol` になってしまうようで、以下の型エラーが出ているのですが、どうすればいいのでしょうか?
```
Cannot pass a value of type `::Symbol` as an argument of type `(:public | :private | :protected)`
  ::Symbol <: (:public | :private | :protected)
    ::Symbol <: :publicRuby::ArgumentTypeMismatch
```
````

## rrdparser.rb の ::BitClust::RRDParser::Context

`singleton_object_class` が引数のところでは `::String?` で、 `if` のところで `::BitClust::ClassEntry?` に変わるというのを steep 1.9.1 が認識してくれなくて、以下のようにコメントを入れると `get_class` の引数も `::BitClust::ClassEntry?` に変わってしまってうまくいかなかった。

```ruby
      def define_object(name, singleton_object_class, location: nil)
        singleton_object_class = @db.get_class(singleton_object_class) if singleton_object_class
        # @type var singleton_object_class: ClassEntry?
        register_class :object, name, singleton_object_class, location: location
      end
```

`@klass` が `nil` の可能性に対応するために `&.` や `|| raise` が増えてしまった。

## methodid.rbs

初期の方針で prototype に残していた inspect などを hand-written にマージした。

## simplesearcher.rbs

破壊的変更は使わずに、配列にも `+=` で追加していて型はつけやすかった。

`cs = ms = []` で初期化して別の型の要素を `+=` で追加していたところは、以下のように分離して型をつけた。

```ruby
      # @type var cs: Array[ClassEntry]
      # @type var ms: Array[MethodEntry]
      cs = []; ms = []
```

以下のようにローカル変数の型が途中で変わるのは難しかったので、変数名を変えた。

```ruby
    def parse_method_spec_pattern0(q)
      q = q.scan(/\S+/)[0..1]
      q = q.reverse unless /\A[A-Z]/ =~ q[0]
      return q[0], nil, q[1]
    end
```

`scan` も正規表現で capture を使っているかどうかで型が変わる (`Array` のネストが変わる) ので、コードの変更なしで決定できないので `_` を経由して回避した。

```ruby
    def parse_method_spec_pattern0(pat)
      # @type var q: Array[String]
      q = _ = pat.scan(/\S+/)[0..1]
      q = q.reverse unless /\A[A-Z]/ =~ q[0]
      return q[0], nil, q[1]
    end
```
