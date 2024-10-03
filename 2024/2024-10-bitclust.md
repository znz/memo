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
