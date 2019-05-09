- あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。
- <https://ruby-trunk-changes.hatenablog.com> へのコメントは *hatenablog* をつけることにしました。
- [rurema](https://github.com/rurema/doctree) 用のメモには *rurema* をつけることにしました。

# 2019-05-09

## [eb84b33c86280a72aaeedae1e582045528c534b2](https://github.com/ruby/ruby/commit/eb84b33c86280a72aaeedae1e582045528c534b2), [025206d0dd29266771f166eb4f59609af602213a](https://github.com/ruby/ruby/commit/025206d0dd29266771f166eb4f59609af602213a)

- [rubyfarm](https://github.com/mame/rubyfarmer) のように特定のコミットを checkout していると detached HEAD になっていて、最初に git 対応したときは大丈夫だったのに [7790b610b8c11ae987e0f9a936418a7a34a8af0b](https://github.com/ruby/ruby/commit/7790b610b8c11ae987e0f9a936418a7a34a8af0b) から、その状態だとブランチ名が空欄になっていたのを対応

## [`Enumerator#with_object` with multiple objects](https://bugs.ruby-lang.org/issues/11797#change-77964)

このチケットの例だけなら

```
["a", "b", "c", "c", "a", "c"].tally.select{@2>1}.map{@1} #=> ["a", "c"]
```

でいけそう。

# 2019-05-08

## [d56b0cb554](https://github.com/ruby/ruby/commit/d56b0cb554dd75190b1d308e20f3f49f5f12571b)

- find.rb を使うと良さそうなことがあったので、ソースをみて気になったところを修正
- [文字リテラル](https://blog.n-z.jp/blog/2017-09-10-ruby-char-literal.html)は今となっては推奨できないので、普通の文字列リテラルにしたのと、ロジックを `start_with?` に変更

## [e8e415b534](https://github.com/ruby/ruby/commit/e8e415b5347197666f4dd11d25df08881ddaa36f)

- コミッター Slack で k0kubun さんが workaround はないかと言っていたのをみて、頑張って考えてみたのを適用

```
chmod -w .ext/common/bigdecimal/*.rb
touch ../ext/bigdecimal/lib/bigdecimal/*.rb
make install
make COPY='cp -f' install
```

で動作確認したので、大丈夫のはず。

`ext` の方の `Makefile` 向けは `CP='cp -f'` ではなく `COPY='cp -f'` だったというのがハマりどころ。

## [c54d5872fb](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190508#c54d5872fb)

- [ ] *hatenablog* `EXPERIMENTL` → `EXPERIMENTAL` ?
- `extconf.rb` に `have_library("xxx")` しか書いていない (`dir_config` がない) gem のインストール時に include dir を指定する方法として `gem install hoge -- --with-xxx-include-dir=/path/to/include` がきかなくて `--with-opt-include=` というのを使う必要があったのを、自動で `dir_config` を呼ぶようにした、という話っぽいです。

# 2019-05-07

- <https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190507>

- admin 権限のある人が間違えて git.ruby-lang.org ではなく github.com に直接 push してしまって同期が壊れた、ということが発生しました。
- admin の push を禁止すると matzbot による同期 push もできなくなるので、 github 側の設定ではうまく対処できないそうです。

- 手元で変更していない force push されたブランチを checkout しなおすには `git checkout -B trunk origin/trunk` とすれば良いようです。

## [5eb5613fef](https://github.com/ruby/ruby/commit/5eb5613fef1c8a72df6843ffce9fc339f14594e8)

- [ruby-commit-hook](https://github.com/ruby/ruby-commit-hook) をいじったので、変なエラーが出ないか、確認を兼ねた無難なコミット。
- ruby-commit-hook の変更の方は push した人の方にメッセージがでない、という現象の対処だったのですが、 `pre-receive` で `2>&1` がついていたらしく、それを削ってなおったようです。

# 2019-05-06

- XDG 系のファイルを扱う便利メソッドが Ruby 本体にあると良いかも、という話がちょっとありました。

## [7e72ce0f73](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190506#7e72ce0f73)

- [ ] *hatenablog* Haiku という BSD 系の OS → BeOS 系?

# 2019-05-05

## [374c8f4eba](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190505#374c8f4eba)

- [ ] *rurema* ARGF.lineno 要確認

## [35ff4ed47f](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190505#35ff4ed47f)

- [ ] *rurema* dump, undump 要確認

# 2019-05-04

- <https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190504>

# 2019-05-03

- <https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190503>

# 2019-05-02

- <https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190502>
- `git checkout -b hoge` のようにブランチで作業すると `git branch --list --format='%(upstream:short)' hoge` は空になるので、そういう時は `last_commit` が出なくなるようになってしまいました。

# 2019-05-01

## [50872f4a15](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190501#50872f4a15)

- `Open3.capture2e` をよく使うけど、似たようなことが `IO.popen(..., &:read)` でできるみたい。

## [0eedec6867](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190501#0eedec6867)

- テザリングしている環境だったからなのか、 index.html が gzip された内容になっていたので、 `Accept-Encoding` を `identity` にして常にエンコーディングなしにしました。
- 同じタイミングで別のマシンに ssh で入ってそこでダウンロードすると gzip されていなかったり、別の http (平文) の html ファイルをダウンロードしても gzip されていなかったりしたので、どういう条件だと gzip されるのかは謎のまま。

## [3de03544ff](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190501#3de03544ff)

- [ ] *hatenablog* 標準添付イブラリ → 標準添付ライブラリ ?
- おそらく Editline 対応で NotImplementedError でこけなくなるテストがあるので、ちゃんと実装するまでの仮対応のようです。
