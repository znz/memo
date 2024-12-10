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
