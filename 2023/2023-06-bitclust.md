# bitclust 作業メモ

## rbs 導入したい 7日目

- `bitclust/server.rb` 対応
- `drb` と `webrick` も使っている部分だけ追加
- `bitclust/database.rb` 対応
- `DRbObject = DRb::DRbObject` のような定数の別名は `DRbObject: singleton(DRb::DRbObject)` のように書けばいいらしい。(`Mutex` を参考にした。)
- `::String` のように `::` をつける書き方を使ってみたが、他のファイルと統一感がなくなっただけかもしれない。

## rbs 導入したい 8日目

- `lib/bitclust/methoddatabase.rb` 対応
- `load_extent` で `def load_extent: (Class entry_class) -> Hash[String, entry_class]` という感じにしたかったけど、 `entry_class` という型はないのでダメだった。 `Class` のところもできれば `Entry` のサブクラスのみにしたい。
- `def fetch_doc: (String name) -> (DocEntry | bot)` のように、バグじゃないときにも例外を投げる可能性のあるものは `| bot` をつけてみている。
- `Location` の `file` に `Pathname` を渡しているところがあったので、受け付けるように緩めた。
- `search_methods` の `result` は `Array[MethodEntry]` ではなく `SearchResult` っぽいが `first` メソッドが定義されてなさそうなので `search_method` で何が返ってきているのかが謎。
- `bitclust/docentry.rbs` は property 関連だけ追加したので、後で他のメソッドの対応が必要。
- `lib/bitclust/methodid.rb` 対応
- `initialize` で受け取らずに直後に `attr_accessor` で設定していて、 `nil` の可能性があるという型エラーをどこかで無視する必要がある。オブジェクトを使う側にも初期化済みかどうかの状態管理の責任を押し付けているので、オブジェクト思考的には良くない設計になっている。ここではとりあえず `initialize` の代入のところでエラーのままにしてみた。

## rbs 導入したい 9日目

- <https://github.com/ruby/rbs/blob/cc6e829765883292f27d867af06340b0caeae4ac/docs/syntax.md#attribute-definition> で `attr_reader foo` などに `@foo` が含まれているので、 `attr_*` があれば `@foo` は不要とわかったので、新しいところからは消した。
- [RBS helper](https://marketplace.visualstudio.com/items?itemName=tk0miya.rbs-helper) で `lib` の省略に対応してもらったので使えるようになった。
- `MethodNamePattern` の `select_classes` から呼ばれている `expand_ic` は存在しなかった。(他のクラスに同名のメソッドはあるが継承関係などにはなっていない。)
- `MethodNamePattern` の `@crecache` と `@mrecache` と `select_classes` は未使用っぽいとわかった。継承して使っているということもなかった。

## rbs 導入したい 10日目

- `methodentry.rbs` の対応途中
- 以下のコメントがあったので、 `BitClust::NameUtils` の方に `type typename = (:singleton_method | :instance_method | :module_function | :constant | :special_variable)` を導入してみた。

```ruby
   # typename = :singleton_method
    #          | :instance_method
    #          | :module_function
    #          | :constant
    #          | :special_variable
    def typename
      methodid2typename(@id)
    end
```

- `typemark` と `typechar` も正常系でとれる値は決まっているので専用の型を用意するのが良いのかもしれないと思って追加した。

## rbs 導入したい 11日目

- `methodentry.rbs` 続き
- `typemark` は他のところにも波及していった
- `typechar` や `typemark` のように値の範囲が固定で決まっている `String` 以外でも `split_method_id` の引数と返り値のように期待される形式が決まっている `String` は個別の型をつけてみるのが良いのかもしれない。
