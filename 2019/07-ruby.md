- あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。
- <https://ruby-trunk-changes.hatenablog.com> へのコメントは *hatenablog* をつけることにしました。
- [rurema](https://github.com/rurema/doctree) 用のメモには *rurema* をつけることにしました。

# 2019-07-02

## [ruby/snapshot も master に変更](https://github.com/ruby/snapshot/pull/8)

- Dockerfile で `git clone` しているので pull request がマージされてイメージが更新されるとデフォルトブランチが trunk から master に変わったものがイメージの中に入るはず
- なので `git pull origin trunk` から `git pull origin master` の変更だけで良いはず
- `snapshot:stable` の方にあわせて、念のため `git checkout master` も追加

という変更です。
