# bitclust 作業メモ

## rbs 導入したい 7日目

- `bitclust/server.rb` 対応
- `drb` と `webrick` も使っている部分だけ追加
- `bitclust/database.rb` 対応
- `DRbObject = DRb::DRbObject` のような定数の別名は `DRbObject: singleton(DRb::DRbObject)` のように書けばいいらしい。(`Mutex` を参考にした。)
- `::String` のように `::` をつける書き方を使ってみたが、他のファイルと統一感がなくなっただけかもしれない。
