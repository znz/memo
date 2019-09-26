- [GitHub Actions Meetup Osaka #0](https://gaug.connpass.com/event/144698/)
- [GitHub Actions Meetup Tokyo β](https://gaugt.connpass.com/event/147220/)

## オープニング

- <https://twitter.com/salamander_jp/status/1177152886125416448>
- <https://docs.google.com/presentation/d/1CQ1XZo0DrMYBhtlSnLIDgPsjMaawuCFgilmEV39yTXo/edit>

## ありふれたCIで世界最強

- <https://twitter.com/salamander_jp/status/1177153538712989697>
- <https://docs.google.com/presentation/d/1l_-b4VZQQSQ2EgjkOHgyz_NjhPFs9mNV67XdbcjoAmY/edit>
- <https://github.co.jp/features/actions>

- 11月13日に GitHub Universe というイベントがある

- <https://github.com/actions/upload-artifact> と <https://github.com/actions/download-artifact> で job をまたいだファイル共有ができるらしい
- workflow ごとに保存されていてダウンロードできるっぽい

## GitHub Actions の通知つらくない?

<!-- homoluctus -->
<!-- ハンズラボ -->

- Template: actions/typescript-action
- Document: creating-a-javascript-action

- homoluctus/slatify
- GitHub Marketplace にも Slatify で登録 (19 stars)

## ruby/actions と ruby/ruby の話

## GitHub Actions に SSH 接続

- tmate
- action-tmate

- https://github.com/mxschmitt/action-tmate/blob/2d4f98f577c97a75566362333d53e911e74f1665/src/main.ts#L29 run
- SSH の接続情報がログに出てこない問題
- <!-- GitHub30/firebase-nuxt-actions --> デバッグ用に Star で動くようにしているアクションがある

## どこで GitHub Actions を実行しているのか

- GitHub Actions と GCP のレイテンシを計測
- gcping
- us-east4 が一番近かった
- GitHub Actions と Azure のレイテンシを計測
- azping
- eastus2 が一番近かった

## repository\_dispatch イベントはいいぞ!

- `on: repository_dispatch`
- github.com/settings/tokens
- Developer Settings → Personal Access Token を生成
- repo public\_repos 権限
