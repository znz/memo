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

## searcher.rb

`DRbObject` になるものインスタンス変数は `# @type var db: MethodDatabase` などで `DRbObject` の可能性を無視したり、
`attr_writer` と `attr_reader` に分離して `attr_reader` では `DRbObject` ではないことにしたりしていた。

`TerminalView` のエンコーディング周りは過去との互換性でごちゃごちゃしているが、
とりあえず型だけ合わせて詳細は今のところ無視した。

`nkf` は Ruby 3.4 で default gem から bundled gem になって、将来外される可能性が高そうということもあり、
`Encoding` だけ対応にして `NKF` 対応のコードは削ってしまっても良さそうだった。

`FunctionEntry` の `db` と `id` が `untyped` のままだったので、そこにも型をつけておいた。

## epub.rbs

`ERB.new` を古い形式で呼び出していて型エラーになっているところがあったので、今のままだと epub 生成は新しい Ruby では動かなそうということがわかった。
とりあえず型優先なので、今は無視だけで新旧両対応は入れなかった。

```ruby
		# steep:ignore:start
		# FIXME: ERB.new のキーワード引数化に対応が必要
		contents = ERB.new(File.read(@templatedir + "contents"), nil, "-").result(binding)
		# steep:ignore:end
```

`EPUBCommand` から渡される `catalog` は常に `nil` なので、
`catalogdir` の typo によるバグっぽい。

`fs_casesensitive` が `bool` ではなく `true?` なのも `false` での初期化忘れというだけかもしれない。

## Dir.mktmpdir

```console
% ruby -r pathname -r tmpdir -e 'Dir.mktmpdir{|outer|n=Pathname(outer);(n+"foo").open("w");Dir.mktmpdir("prefix-", outer){}}'
% ruby -r pathname -r tmpdir -e 'Dir.mktmpdir{outer=Pathname(_1);Dir.mktmpdir("prefix-", outer){}} rescue p $!'
#<ArgumentError: empty parent path>
```

## completion.rb

長くて非常にたいへん。

```ruby
  # Provides completion search methods like _search_classes, _search_methods.
  # Included by MethodDatabase and FunctionDatabase.
```

と書いてあるので、それぞれのクラスからしか呼ばれていないメソッドには `# @type self: MethodDatabase` などで `self` のクラスを確定するようにした。

デバッグ用っぽいインデントなしのコードやコメントがあるので、消していいのかどうか悩む。

`SearchResult::Record.new` の引数はバグってるところがありそう。

`SearchResult::Record` の `@idstring` が常に `nil` なので `idstring` ではなく `@idstring` を参照しているところはバグっぽい。

`search_methods_from_cname_mname` の `SearchResult.new(self, pattern, recs.map {|rec| rec.class_name }, recs)` だけ第3引数が `Array[ClassEntry]` ではなく `Array[String]` になっているのでバグかもしれない。

## ridatabase.rbs

昔の RDoc に依存していて、今の RDoc だとクラス階層などが変わっていて動かなくなっているので、
正しいかどうかはわからないが、型エラーがでないようにするためにある程度の型付けをした。

## requesthandler.rb

`URI.unescape` の置き換えは何にするか悩んだが、とりあえず依存が増えなさそうな `ERB::Util.url_encode` にした。

## いくつかの型エラー対応

`$KCODE` は `Encoding` によるガードがあるので単純に無視すれば良さそうだった。

`screen.rb` のは `group_by` や `flatten!` での型の変化の問題のなので、無視した。

```diff
diff --git a/lib/bitclust/runner.rb b/lib/bitclust/runner.rb
index b49e6c1..e50db85 100644
--- a/lib/bitclust/runner.rb
+++ b/lib/bitclust/runner.rb
@@ -3,7 +3,7 @@ require 'pathname'
 require 'optparse'

 unless Object.const_defined?(:Encoding)
-  $KCODE = 'UTF-8'
+  $KCODE = 'UTF-8' # steep:ignore
 end

 def libdir
diff --git a/lib/bitclust/screen.rb b/lib/bitclust/screen.rb
index b0c9499..e4a69b6 100644
--- a/lib/bitclust/screen.rb
+++ b/lib/bitclust/screen.rb
@@ -542,14 +542,16 @@ module BitClust
	 def draw_tree(cs, &block)
	   return if cs.empty?
	   if cs.first.class?
-        tree = cs.group_by{|c| c.superclass }
+        tree = cs.group_by{|c| c.superclass } # steep:ignore
		 tree.each {|key, list| list.sort_by!{|c| c ? c.name : "" } }
		 roots = tree.keys.select{|c| !c || !cs.include?(c) }
-        roots.map!{|c| tree[c] }.flatten!
+        roots.map!{|c| tree[c] }.flatten! # steep:ignore
	   else
		 tree = {}
		 roots = cs
	   end
+      # @type var roots: Array[ClassEntry]
+      # @type var tree: Hash[ClassEntry, Array[ClassEntry]]
	   draw_treed_entries(roots, tree, &block)
	 end

diff --git a/sig/hand-written/bitclust/screen.rbs b/sig/hand-written/bitclust/screen.rbs
index 91c823e..418a62a 100644
--- a/sig/hand-written/bitclust/screen.rbs
+++ b/sig/hand-written/bitclust/screen.rbs
@@ -94,6 +94,9 @@ module BitClust
	 def document_url: (String name) -> ::String

	 def canonical_url: (String current_url) -> String
+
+    # defined in URLMapperEx
+    def edit_url: (Location location) -> String
   end

   class TemplateRepository
```


`edit_url` は `screen.rb` での以下の部分の問題で `@urlmapper` が `URLMapperEx` のときしか呼ばれていないはずのメソッドなので、
`URLMapper` に `edit_url` も足してごまかすことにした。

```ruby
	def edit_url(location)
	  @urlmapper.edit_url(location)
	end
```

## functionentry.rbs

`params` に `nil` が代入されていて、 `lib/bitclust/functionreferenceparser.rb` で `f.params = h.params || raise` にすると `bitclust update` で失敗してしまうので、 `String?` にしていたが、以下の `empty?` が `nil` に定義されていない、という型エラーになったので、型では `attr_reader` と `attr_writer` を分離して回避した。

```ruby
	def callable?
	  not params().empty?
	end
```

```rbs
	attr_reader params: String
	attr_writer params: String?
```
