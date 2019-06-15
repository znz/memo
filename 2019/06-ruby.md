- あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。
- <https://ruby-trunk-changes.hatenablog.com> へのコメントは *hatenablog* をつけることにしました。
- [rurema](https://github.com/rurema/doctree) 用のメモには *rurema* をつけることにしました。

# 2019-06-14

## [d780c36624](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20190614#d780c36624)

- コミッター Slack で2回つついてみたけど追加されなかったので、自分で追加しました。
- pipeline operator の時に experimental とつけ忘れたとどこかで言っていたはずなので、追加すること自体は問題ないはず。

# 2019-06-13

## [1808029061](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20190613#1808029061)

- [ ] *hatenablog* `make ync-default-gems` → `make sync-default-gems` ?

## developer meeting

- このチケットで時間がかかるのか、というのもいくつかあって、リストに上がっていたチケットは途中までで終わったけど、 pipeline operator `|>` が実験的に入ったり、 numbered parameter が `|e|` 相当のものがいいのか `|e,|` 相当のものがいいのか再度議論していたりした。

# 2019-06-04

## expand tabs が動いていないことがあったのを修正

<https://github.com/ruby/ruby/blob/9a07915ae21d5a8e39d7dab6b609be033f2e2d7d/proc.c#L87> をみて expand tabs が動いてないなと思って調べてみたところ、
複数 revision をまとめて push した時に最新しかチェックされていなかったのが原因でした。

`git clone --depth=10 https://github.com/ruby/ruby /tmp/ruby.git` (10 は ca22cccc14e17d21b4fe7b5aed680e9edf12afb7 を含むための適当な数) で clone してきて、 `git rebase -i ca22cccc14e17d21b4fe7b5aed680e9edf12afb7` で `790a1b17902f7ccb5939b9e0314571079fc30bc8` より新しいコミットを削除して、
`ruby -C /tmp/ruby.git $(pwd)/bin/auto-style.rb /tmp/ruby.git ca22cccc14e17d21b4fe7b5aed680e9edf12afb7 790a1b17902f7ccb5939b9e0314571079fc30bc8 trunk`
`ruby bin/auto-style.rb /tmp/ruby.git ca22cccc14e17d21b4fe7b5aed680e9edf12afb7 790a1b17902f7ccb5939b9e0314571079fc30bc8 trunk`
で動作確認しました。

[bin/auto-style.rb で最新以外のコミットもみる変更](https://github.com/ruby/ruby-commit-hook/pull/15) の動作確認のテストコミットをしてみた結果、
<https://github.com/ruby/ruby/commit/ce4b5d90b2127af185f91037de1185ad7520ace3> で正常に動作しているのを確認できました。

# 2019-06-03

- https://qiita.com/gotchane/items/1d6069c2bd4ecd5c386b からリンクされてる https://bugs.ruby-lang.org/issues/12961 の話を出してみたら `Float::INFINITY` が終端の Range についての議論が活発に。
