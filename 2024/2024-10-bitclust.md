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
```
begin
  p $stdin.read_nonblock(10)
rescue IO::WaitReadable => e
  p e.message
end
```
で `Type `::IO::WaitReadable` does not have method `message`(Ruby::NoMethod)` になるのですが、こういうモジュールはどう型を付ければいいんでしょうか?
