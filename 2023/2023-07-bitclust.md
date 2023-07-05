# bitclust 作業メモ

## rbs 導入したい 13日目

- `classentry.rbs` の続き
- `def each: () { (MethodEntry) -> untyped } -> untyped` でブロックの返り値を無視しているというのが `untyped` でいいのかがわからない
- `Struct` をどうすればいいのかわらないので、 `ruby/rbs` を参考にして `class Parts < Struct[untyped]` にしたが、 `Parts` に代入しているところは型エラーになっている
- `attr_reader` じゃなくても `reader` メソッドとインスタンス変数の型が同じなら `attr_reader` を使う方がいいのかどうかが悩ましい
- むしろインスタンス変数は `nil` の可能性があっても参照する方では `nil` の可能性がないなら、 `attr_reader` でも別々に書く方が良いのかもしれない

## rbs 導入したい 14日目

- `textutils.rbs` に型付け
- `textutils.rb` は `untyped` だらけでエラーなしから `nil` の可能性を誤検知してエラーありになった
