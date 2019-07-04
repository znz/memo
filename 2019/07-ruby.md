- あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。
- <https://ruby-trunk-changes.hatenablog.com> へのコメントは *hatenablog* をつけることにしました。
- [rurema](https://github.com/rurema/doctree) 用のメモには *rurema* をつけることにしました。

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
