# bitclust 作業メモ

## untyped 減らし中

### methoddatabase.rb

rbs の方では
`[T] (singleton(T) entry_class) -> Hash[String, T]`
のような定義が `singleton(T)` でエラーになって使えないので、
とりあえず使われているクラスを列挙した。

`id_extent` は `type_id` しか使っていないので、
`interface _TypeId` を追加して統一してみた。

```rbs
    # entry_class < Entry, Hash[String, entry_class]
    def load_extent: (singleton(DocEntry) entry_class) -> Hash[String, DocEntry]
                   | (singleton(LibraryEntry) entry_class) -> Hash[String, LibraryEntry]
                  #  | (untyped entry_class) -> Hash[String, untyped]

    interface _TypeId
      def type_id: () -> Symbol
    end

    def id_extent: (_TypeId entry_class) -> Array[String]
```

ローカル変数の `Hash` の値は `instance(entry_class)` のような型にはできないので、
`untyped` のままにするしかなさそうだった。

```ruby
    def load_extent(entry_class)
      # @type var h: Hash[String, untyped]
      h = {}
      id_extent(entry_class).each do |id|
        h[id] = entry_class.new(self, id)
      end
      h
    end
    private :load_extent

    def id_extent(entry_class)
      entries(entry_class.type_id.to_s)
    end
    private :id_extent
```
