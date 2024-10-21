# bitclust 作業メモ

## typeprof

ちょっと試してみていたコマンドでまた試してみたが <https://github.com/ruby/typeprof/issues/274> で動かず。

## lib/bitclust/subcommands/chm_command.rb

- `cname, tmark, mname = *split_method_spec(spec)`
  の `*` の配列展開で `nil` の可能性が追加されてしまう問題は
  対応を待つのをあきらめて
  `cname, tmark, mname = split_method_spec(spec)`
  に書き換えた。
- `FileUtils.cp` の `{:verbose => true, :preserve => true}` を `verbose: true, preserve: true` に変更。

## lib/bitclust/subcommands/extract_command.rb

困ったので ruby-jp slack で質問した。

<https://github.com/rurema/bitclust/blob/2a2028ac761cee63a27eb24f7b6673da4b9fbd3e/lib/bitclust/subcommands/extract_command.rb#L32> で問題があって、似たようなモジュールの `IO::WaitReadable` が参考になるかと思って同じように書いてみたら、

```ruby
begin
  p $stdin.read_nonblock(10)
rescue IO::WaitReadable => e
  p e.message
end
```

で ``Type `::IO::WaitReadable` does not have method `message`(Ruby::NoMethod)`` になるのですが、こういうモジュールはどう型を付ければいいんでしょうか?

結局、以下のように型を付け直す workaround を入れて型エラーを回避することにした。

```ruby
          rescue WriterError => err
            # @type var err: StandardError
            err = _ = err
```

## exception.rbs

他の場所でも同じことが起きていたので、結局モジュールに存在しないメソッド定義の型を足すことにした。

```rbs
  module WriterError
    # 型エラー回避のため Exception#message の型をコピー
    def message: () -> String
  end
```

`backtrace` からメソッドチェーンしているところの型エラーもあったので、型定義を上書きすることにした。

```rbs
  class Error < StandardError
    # 型エラー回避のため、nilの可能性を外した。
    def backtrace: () -> Array[String]
  end
```

## subcommand.rbs

```ruby
    def align_progress_bar_title(title)
      size = title.size
      if size > 14
        title[0..13]
      else
        title + ' ' * (14 - size)
      end
    end
```

に対して、

```rbs
def align_progress_bar_title: (untyped title) -> String
```

と書いていたのを

```rbs
def align_progress_bar_title: (String title) -> String
```

にしたら、返り値が `String | nil` という型エラーになったので、

```ruby
        title[0..13] #: String
```

とコメントを追加してみたけど、 `nil` の可能性はないと教えたいだけなのに、正しく推測された `String` を書かないといけなくて、将来たとえば `string` の方がいいかなと思って書き換えたときに余計な手間が増えそうだし、複雑な型だったときには書くのも大変そう。

なので `nil` の可能性はない、というのだけ明示できると便利そう。

ruby-jp slack の `#types` で `or raise` しかなさそうということだったので書き換えた。

## methodsignature.rbs

`attr_reader` と重複していたインスタンス変数の型定義を削除して型をつけた。

`methodsignature.rb` は `|| raise` の追加や `&.` への変更をした。

## htmlutils.rbs

ほとんど `String` に型付け。

`unescape_html` は `ESCrev` に入っている 4 種類以外の `/&\w+;/` は `nil` に `gsub` されるようなので、使わない方が良さそう。

## rdcompiler.rbs

`|| raise` や `&.` の対応をたくさん入れた。

`props = {} #: Hash[String?, String?]` のように空ハッシュで初期化している変数の型を明示した。

```ruby
filename = (caption&.size || 0) > 2 ? caption : @f.name #: String
```

と変更しかけていたところは `align_progress_bar_title` と同様に

```ruby
filename = (caption&.size || 0) > 2 ? caption : @f.name or raise
```

にした。

named capture でのローカル変数は `untyped` になっていたので `@type var` で明示した。

```ruby
      if %r!\A//emlist\[(?<caption>[^\[\]]+?)?\]\[(?<lang>\w+?)\]! =~ command
        # @type var caption: String?
        # @type var lang: String
```

型合わせのために無理矢理式を変えてしまったところもある。

```diff
-      level = @hlevel + (line.slice(/\A=+/).size - 3)
+      level = @hlevel + (line.slice(/\A=+/)&.size.to_i - 3)
```

`escape_table` の型をゆるめるのか `char` の型を厳密にするのかが悩ましかったところ。

```diff
     def compile_text(str)
       escape_table = HTMLUtils::ESC
       str.gsub(/(#{NeedESC})|(#{BracketLink})/o) {
-        if    char = $1 then escape_table[char]
-        elsif tok  = $2 then bracket_link(tok[2..-3])
+        # @type var char: '&' | '"' | '<' | '>'
+        if    char = _ = $1 then escape_table[char]
+        elsif tok  = $2 then bracket_link(tok[2..-3] || raise)
         elsif tok  = $3 then seems_code(tok)
         else
           raise 'must not happen'
```

ここは引数によっては本当に `nil` の可能性があるので仕方がなさそう。

```diff
     def bracket_link(link, label = nil, frag = nil)
       type, _arg = link.split(':', 2)
-      arg = _arg.rstrip
+      arg = _arg&.rstrip or raise
       case type
       when 'lib'
```

インスタンス変数の型は一部だけ変更はできないので、ローカル変数で型を上書きした。
`edit_url` が `URLMapper` になくて `URLMapperEx` にあったので、ここはそれのはず、ということで本当にそうなのかのチェックはまだしていないので、
今後のソースコードリーディングで確認したい。

```diff
         string rdoc_link(@method.id, @option[:database].properties["version"])
         if @option[:edit_base_url] && @method.source_location
           string ']['
-          string a_href(@urlmapper.edit_url(@method.source_location), 'edit')
+          # @type var urlmapper: ::BitClust::Subcommands::StatichtmlCommand::URLMapperEx
+          urlmapper = _ = @urlmapper
+          string a_href(urlmapper.edit_url(@method.source_location), 'edit')
         end
         string ']</span>'
       end
```

## statichtml_command.rb

- `cname, tmark, mname = *split_method_spec(spec)` の `*` を削除。
- `Dir.mktmpdir` を使っていたので、 `rbs_collection.yaml` に `tmpdir` を追加。

以下の `ensure` の `verbose` がなぜか `untyped` になる。(代入の結果が `bool | nil` なので or `nil` の可能性が足されても `bool | nil` のままになるはず?

```ruby
          begin
            verbose, $VERBOSE = $VERBOSE, false
            Encoding.default_external = 'utf-8'
          ensure
            $VERBOSE = verbose
          end
```

`screen.rbs` の `URLMapper` の型も書き換えつつ対応した。

親クラスと同じ型でいいと思ってメソッドの型を消すと `bundle exec rake sig` の `rbs prototype rb` で `untyped` で生成されてしまうので、結局残しておくしかなかった。

## screen.rbs

```ruby
    def new_screen(c, *args)
      c.new(@conf, *args)
    end
```

のようにクラスを受け取ってそのインスタンスを返すメソッドの型って untyped だらけにするしかない?

```rbs
    def new_screen: (c: singleton(Foo), *args) -> Foo
                  | (c: singleton(Bar), *args) -> Bar
```

という方法を教えてもらって、クラスがわかっている範囲で書き換えた。


```ruby
    def edit_url(location)
      @urlmapper.edit_url(location)
    end
```

で `URLMapper#edit_url` がない (`URLMapperEx` にはある) という問題にまたひっかかったが、
`URLMapperEx` が `statichtml_command.rb` だけではなく `chm_command.rb` にもあって、
`edit_url` 自体を `URLMapper` にも定義した方がいいのでは、と思って、ここのエラーはいったん保留にした。

https://github.com/rurema/bitclust/blob/2a2028ac761cee63a27eb24f7b6673da4b9fbd3e/lib/bitclust/screen.rb#L548
の

```ruby
        roots.map!{|c| tree[c] }.flatten!
```

の部分が無理そうなので、 ruby-jp#types で相談。

> `Array[T]` が `map!` で一瞬 `Array[Array[T]]` になって `flatten!` で `Array[T]` に戻る、っていい感じに型を付けるのは無理そうという認識であっているでしょうか?
> 試しに `roots` を `Array[T | Array[T]}` にすると、 `tree` が `Hash[T, Array[T]]` なので、 `tree[c]` で赤色波線の `Ruby::ArgumentTypeMismatch` になって、現状の `{|c| tree[c] }` が黄色波線の `Ruby::BlockBodyTypeMismatch` より状況が悪化してしまう。

## list_command.rbs

```ruby
          @db.libraries.map {|lib| lib.name }.sort.each do |name|
```

の `@db` が `(::BitClust::FunctionDatabase | ::BitClust::MethodDatabase)` で

```
Type `(::BitClust::FunctionDatabase | ::BitClust::MethodDatabase)` does not have method `libraries`(Ruby::NoMethod)
```

になってしまうので、

```ruby
          db = @db
          db.is_a?(MethodDatabase) or raise
          db.libraries.map {|lib| lib.name }.sort.each do |name|
```

にしたが、 `--function` だけでは `FunctionDatabase` にならないとわかって、
サブコマンドの前のグローバルオプションの方での `--capi` も必要だったので、

```ruby
        when :function
          db = @db
          db.is_a?(FunctionDatabase) or raise "invalid database given. Use with --capi option"
          db.functions.sort_by {|f| f.name }.each do |f|
```

のように具体的にどうすればいいかを含むエラーメッセージをつけた。

試したコマンド例:

```shell
bundle exec bitclust -d /tmp/db-3.4 list --library
bundle exec bitclust -d /tmp/db-3.4 list --class
bundle exec bitclust -d /tmp/db-3.4 list --method
bundle exec bitclust -d /tmp/db-3.4 list --function
bundle exec bitclust -d /tmp/db-3.4 --capi list --function
bundle exec bitclust -d /tmp/db-3.4 --capi list --method
```

`parse` と `exec` はどのサブコマンドも同じ型にすれば良さそうだったので、
`sd` コマンドで置き換えることにした。

```shell
sd -s 'def parse: (untyped argv) -> untyped' 'def parse: (Array[String] argv) -> void' sig/hand-written/bitclust/subcommands/*.rbs
sd -s 'def exec: (untyped argv, untyped options) -> untyped' 'def exec: (Array[String] argv, Hash[Symbol, String?] options) -> void' sig/hand-written/bitclust/subcommands/*.rbs
```

## rrdparser.rbs

`_ToIO | _ToStr s` にしてみたら ``Type `(::_ToIO | ::_ToStr)` does not have method `respond_to?`(Ruby::NoMethod)`` と言われてしまうので、どうすればいいのかわからなかった。

```ruby
      if s.respond_to?(:to_io)
        io = s.to_io
      elsif s.respond_to?(:to_str)
        s1 = s.to_str
```

`methods_command.rb` のために `RRDParser.parse_stdlib_file` の返り値の型がほしかったので、そのあたりだけ型を追加した。

`Object &` をつけるという案を教えてもらって試した結果、以下のようにダメだった。

```
    def self.parse: (Object & (_ToIO | _ToStr) s, String lib, ?::Hash[String, String] params) -> [LibraryEntry, MethodDatabase]
```
にしてみましたが、
```
Type `(::Object & (::_ToIO | ::_ToStr))` does not have method `to_io`(Ruby::NoMethod)
Type `(::Object & (::_ToIO | ::_ToStr))` does not have method `to_str`(Ruby::NoMethod)
```
になったので、 https://github.com/soutaro/steep/issues/560 の対応が入らないと `*.rb` 側の変更なしでは無理そうでした。

## methoddatabase.rbs

同様に関連する `self.dummy` や `attr_writer refs` にだけ型を追加した。

## crossrubyutils.rbs

`methods_command` が依存していた `crossrubyutils` を先に型付け。

`ENV['PATH']` を `ENV.fetch('PATH')` に変更。

```ruby
    def forall_ruby(path, &block)
      rubys(path)\
          .map {|ruby| [ruby, `#{ruby} --version`] }\
          .reject {|ruby, verstr| `which #{ruby}`.include?('@') }\
          .sort_by {|ruby, verstr| verstr }\
          .each(&block)
    end
```

の `sort_by` のブロックと `each(&block)` の `&block` が `Ruby::BlockBodyTypeMismatch` になる。

steep が `*` に対応していないので、

```ruby
    def print_crossruby_table(&block)
      print_table(*build_crossruby_table(&block))
    end
```

を

```ruby
    def print_crossruby_table(&block)
      vers, table = build_crossruby_table(&block)
      print_table(vers, table)
    end
```

に変更。

他は推論された型を `rbs` ファイルに記入していくのがほとんどだった。

## methods_command.rbs

```ruby
          raise "must not happen: #{mode.inspect}"
```

の `mode` が

```
Type `::BitClust::Subcommands::MethodsCommand` does not have method `mode`(Ruby::NoMethod)
```

になっていて、 `@mode` の間違いというバグがみつかった。

`m_order` は `*` がなくても `split` の返り値の型の問題があったので `or raise` の行を追加した。

```ruby
      def m_order(m)
        m, t = *m.reverse.split(/(\#|\.|::)/, 2)
        m or raise
        t or raise
        [ORDER[t] || 0, m.reverse]
      end
```

## classes_command.rbs

methods_command の一部と同じだった。

## preprocessor.rbs

方針変更前の `prototype` が残っていたのをマージした。

`::BitClust::LineCollector` が間違えて `::BitClust::Preprocessor::LineCollector` になっていたのを修正した。

```ruby
    def LineCollector.process(path)
      fopen(path) {|f|
        return wrap(f).to_a
      }
    end
```

の `to_a` で型エラーになっていた。

`each` の型が間違っているのかと思い、 `def each: () { (String) -> void } -> void` に修正したが `to_a` は直らず。

`LineCollector.process` の返り値が `instance` ではなく `Array[String]` が正しかった。
(`wrap` の返り値がそのまま返るのではないため)

## 中断して webrick

webrick を必要なところだけ型付けしていくのが不便に感じ始めたので、
https://github.com/ruby/webrick/pull/115
を参考にして `rbs prototype rb` をベースに型付けし始めているけど、
typeprof で生成された https://github.com/ruby/webrick/blob/fb719152938719deadd21835153b9ed7bd1bb5dc/sig/webrick.rbs#L53-L56 の絞り込めていない感じが面白かった。
https://github.com/ruby/webrick/blob/9350944141a3f15acda9c79edd5393289c098e04/lib/webrick/httputils.rb#L233-L249 なので、書きかけの型ファイルでは

```rbs
    def self?.parse_qvalues: (String? value) -> Array[String]
```

にしている。

## webrick 続き

`singleton` や `socket` への依存がある。
`uri` も。

timeout handler 周りは `timeout` ライブラリに合わせて、
`Numeric` や `singleton(Exception)` にした。

cancel 用の id は `object_id` だったので、
`Integer` にした。

`watch` は `while true` の無限ループで `return` するところもなさそうだったので `bot` になった。

```rbs
def self.register: (Numeric seconds, singleton(Exception) exception) -> Integer
def self.cancel: (Integer id) -> boola
def watch: () -> bot
```

`class GenericServer` が `webrick/ssl` でも上書きされていて、ちょっと難しい。

`webrick/httpstatus` `const_set` されている定数は以下で補った。

```ruby
require 'webrick'

puts WEBrick::HTTPStatus::constants.grep(/\ARC_/).map{"#{_1}: #{WEBrick::HTTPStatus.const_get(_1)}"}

puts WEBrick::HTTPStatus::CodeToError.each_value.map{"class #{_1.name.split(/::/).last} < #{_1.superclass.name.split(/::/).last}\nend"}
```

`webrick/httprequest` の `@form_data` は `nil` で初期化されているだけで未使用だった。
`@addr` と `@peeraddr` は `nil` ではなく `[]` で初期化の方が型が絞れそう。
`@query` や `@header` も `nil` ではなく `{}` で初期化の方が型が絞れそう。

## webrick 続き

```text
Non-overloading method definition of `parse` in `::WEBrick::HTTPRequest` cannot be duplicated(RBS::DuplicatedMethodDefinition)
```

は `https.rbs` に重複定義があったので、 `| ...` を追加して、

```rbs
    alias orig_parse parse

    def parse: (?(TCPSocket | OpenSSL::SSL::SSLSocket)? socket) -> void
             | ...

    alias orig_parse_uri parse_uri

    private

    def parse_uri: (String str, ?::String scheme) -> URI::Generic
                 | ...

    public

    alias orig_meta_vars meta_vars

    def meta_vars: () -> Hash[String, String]
                 | ...
```

などとしていって解決した。

## webrick 続き `webrick/httpresponse`

`webrick/httpresponse` は `body` に悩んで、コメントの

```ruby
    # Body may be:
    # * a String;
    # * an IO-like object that responds to +#read+ and +#readpartial+;
    # * a Proc-like object that responds to +#call+.
```

を参考にして、

```rbs
    interface _CallableBody
      def call: (_Writer) -> void
    end

    attr_accessor body: String | _ReaderPartial | _CallableBody
```

にした。

`#read` は呼ばれていなかったので、 `_Reader & _ReaderPartial` ではなく `_ReaderPartial` だけにした。

書き込みは `write` のみだったので、 `socket` の型は `_Writer` にした。

`=` つきのメソッドの返り値でちょっと悩んでしまったが、右辺の値の型をそのまま書くようだったので、そうしておいた。

`set_redirect` は `singleton` を使って

```rbs
    def set_redirect: (singleton(WEBrick::HTTPStatus::Redirect) status, URI::Generic | String url) -> bot
```

にした。
<https://github.com/ruby/webrick/blob/9350944141a3f15acda9c79edd5393289c098e04/lib/webrick/httpresponse.rb#L391-L393>
の `Example` の `res.set_redirect WEBrick::HTTPStatus::TemporaryRedirect` は引数が足りてなさそう。

<https://github.com/ruby/webrick/blob/fb719152938719deadd21835153b9ed7bd1bb5dc/sig/webrick.rbs#L518> で `nil ex` になっているのが気になったが、
実際に使われているところでは `nil` は来なさそうだったので、

```rbs
    def set_error: (singleton(Exception) ex, ?bool backtrace) -> void
```

にした。

`write` の引数になるものは `_Writer` での定義に合わせて `_ToS` を使った。

## webrick/httprequest

`IO?` 型が渡せなくなるらしいので、 `IO socket` を `IO? socket` に変更した方がいいかもしれないが、返り値も `String?` になってしまうので、とりあえずそのままにした。
`void` は返り値以外で書ける位置が制限されているらしいので `top` に変更。

```rbs
    def read_body: (IO socket, body_chunk_block block) -> String
                 | (nil socket, top block) -> nil
```

### webrick 続き webrick/httpservlet/abstract.rbs と webrick/httpservlet/filehandler.rbs

`AbstractServlet` は `@config` が `HTTPServer` で `FileHandler` は `Hash[Symbol, untyped]` で困ったので、

```rbs
    class AbstractServlet
      @server: HTTPServer

      interface _Config
        def []: (Symbol) -> untyped
      end

      @config: _Config
```

にした。

`@options` も `AbstractServlet` は `Array[untyped]` で `FileHandler` は `Hash[Symbol, untyped]` なので、
`AbstractServlet` の方は `untyped` にした。

`do_GET` などが `AbstractServlet` は `-> bot` で `FileHandler` で `-> void` にしたのは型エラーにはならなかった。

### webrick 続き

まだ手をつけてなかった自動生成されただけの `cgi.rbs` に型エラーがあると思ったら、こんな感じで `include Enumerable[untyped]` になっていないからだった。

```console
% cat a.rb
class C
  include Enumerable

  def each
    yield nil
  end
end
% rbs prototype rb a.rb
class C
  include Enumerable

  def each: () { (untyped) -> untyped } -> untyped
end
```

`webrick/httpserver.rbs` で

```ruby
    def mount_proc(dir, proc=nil, &block)
      proc ||= block
      raise HTTPServerError, "must pass a proc or block" unless proc
      mount(dir, HTTPServlet::ProcHandler.new(proc))
    end
```

に対応する型として、

```rbs
    def mount_proc: (String dir, ?HTTPServlet::ProcHandler::_Callable proc) -> void
                  | (String dir, ?nil proc) { (HTTPRequest, HTTPResponse) -> void } -> void
```

としてみた。
