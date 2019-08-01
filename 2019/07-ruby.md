- あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。
- <https://ruby-trunk-changes.hatenablog.com> へのコメントは *hatenablog* をつけることにしました。
- [rurema](https://github.com/rurema/doctree) 用のメモには *rurema* をつけることにしました。

# 2019-07-31

## [14eede6e53](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20190731#14eede6e53)

`Leaked thread: Rinda::TestRingServer#test_ring_server_ipv6_multicast` が時々発生していた原因は
https://github.com/ruby/ruby/blob/575735664b1b77924ffdc9faf87c44c67d9be363/test/rinda/test_rinda.rb#L628-L630 で止めた後に
https://github.com/ruby/ruby/blob/67f7e5a224bc31e1625023ce1ed5cfbd54ea1d8f/lib/rinda/tuplespace.rb#L615 で別スレッドが起動するからでした。

`make test-all RUBYOPT=-w TESTS='-v rinda/test_rinda.rb -n test_ring_server_ipv6_multicast'` で割と高頻度に再現して、
デバッグプリントを入れると、入れる場所によっては再現しなくなることが多いので、調べるのはちょっと大変でした。

## [72825c35b0](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20190731#72825c35b0)

`hash_iter_lev` に変な値を設定していても確かに大丈夫そうでした。

```
>> def hrec h, n, &b; if n > 0; h.each{hrec(h, n-1, &b)}; else; yield; end; end
=> :hrec
>> h=Marshal.load(Marshal.dump({a:1}.tap{@1.instance_variable_set(:@ash_iter_lev, :test)}).tr('@','h'))
=> {:a=>1}
>> Marshal.dump h
=> "\x04\bI{\x06:\x06ai\x06\x06:\x12hash_iter_lev:\ttest"
>> hrec(h, 1000) {}
=> {:a=>1}
>> Marshal.dump h
=> "\x04\bI{\x06:\x06ai\x06\x06:\x12hash_iter_levi\x00"
```

# 2019-07-14

- `sed -i '' -e 's/\[Feature #\([0-9]*\)\]/[[feature:\1]]/g' refm/doc/news/2_6_0.rd`
- `sed -i '' -e 's/\[Bug #\([0-9]*\)\]/[[bug:\1]]/g' refm/doc/news/2_6_0.rd`
- `sed -i '' -e 's/https*:[^ ]*/[[url:&]]/g' refm/doc/news/2_6_0.rd`
- `'https?'` の `?` がきかなかったので `*` で代用

# 2019-07-09

- [Enumerable#select(pattern) #2271](https://github.com/ruby/ruby/pull/2271)
- [Enumerable#select(pattern) #73](https://github.com/ko1/rubyhackchallenge/issues/73)
- [Feature #14197 `Enumerable#{select,reject}` accept a pattern argument](https://bugs.ruby-lang.org/issues/14197)

# 2019-07-03

## [e44c9b1147](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20190703#e44c9b1147)

- `Tempfile#initialize` の `define_finalizer` で例外になって、 `super` の `__setobj__` が呼ばれていなくて `not delegated` になっていたようなので、本来の原因とは無関係な例外を減らすための変更です。
- `SystemStackError` なので `rb_objspace_reachable_objects_from` で辿りすぎているのではないかという可能性があるようです。
- `Tempfile::Remover` でも警告が出るので、かなり謎です。

## [07e9a1d9986b36d9702b480de549c1301dd897e0](https://github.com/ruby/ruby/commit/07e9a1d9986b36d9702b480de549c1301dd897e0)

- これも timestamp ファイルの時と同様に clock skew を疑っています。

# 2019-07-02

## [ruby/snapshot も master に変更](https://github.com/ruby/snapshot/pull/8)

- Dockerfile で `git clone` しているので pull request がマージされてイメージが更新されるとデフォルトブランチが trunk から master に変わったものがイメージの中に入るはず
- なので `git pull origin trunk` から `git pull origin master` の変更だけで良いはず
- `snapshot:stable` の方にあわせて、念のため `git checkout master` も追加

という変更です。
