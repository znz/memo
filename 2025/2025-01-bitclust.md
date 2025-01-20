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

### app.rbs

`--auto` のときかどうかで `:dbpath` の型が変わっていたので、別 type にわけて `:viewpath` の有無も表現するようにした。

```rbs
    type options_auto = {
      # auto
      :dbpath => Array[String],
      :baseurl => String?,
      :datadir => String?,
      :templatedir => String?,
      :theme => String?,
      :encoding => String,
      :capi => bool,
    }
    type options_noauto = {
      :viewpath => String,
      :dbpath => String?,
      :baseurl => String?,
      :datadir => String?,
      :templatedir => String?,
      :theme => String?,
      :encoding => String,
      :capi => bool,
    }
    type options = options_auto | options_noauto

    @options: options
```

### server_command.rb

`server.mount viewpath, interface` で最低限だけ抜き出すと以下のようになっている `BitClust::Interface` が追加している `WEBrick::HTTPServer::_GetInstance` として受け付けられるのを期待したのに受け付けられなかったので、明示的に `BitClust::Interface` を受け付けるようにした。

```rbs
module BitClust
  class Interface
    def get_instance: (untyped server) -> WEBrickServlet
  end

  class WEBrickServlet < ::WEBrick::HTTPServlet::AbstractServlet
  end
end

# webrick/sig/httpservlet/abstract.rbs
module WEBrick
  module HTTPServlet
    class AbstractServlet
      def service: (HTTPRequest req, HTTPResponse res) -> void
	end
  end
end
```

```rbs
# bitclust/sig/webrick.rbs
module WEBrick
  class HTTPServer < ::WEBrick::GenericServer
    interface _Service
      def service: (HTTPRequest req, HTTPResponse res) -> void
    end

    interface _GetInstance
      def get_instance: (HTTPServer, *untyped options) -> _Service
    end

    def mount: (String dir, singleton(HTTPServlet::AbstractServlet) servlet, *untyped options) -> void
             | (String dir, _GetInstance servlet, *untyped options) -> void
             | (String dir, BitClust::Interface servlet, *untyped options) -> void # なぜか _GetInstance にならないようなので明示的に許可
             | ...
  end
end
```

`_GetInstanceWithOptions` と `_GetInstanceWithoutOptions` に分離した。

```rbs
    interface _GetInstanceWithOptions
      def get_instance: (HTTPServer, *untyped options) -> _Service
    end

    interface _GetInstanceWithoutOptions
      def get_instance: (HTTPServer) -> _Service
    end

    def mount: (String dir, singleton(HTTPServlet::AbstractServlet) servlet, *untyped options) -> void
             | (String dir, _GetInstanceWithOptions servlet, *untyped options) -> void
             | (String dir, _GetInstanceWithoutOptions servlet) -> void
             | ...
```

### entry.rbs

```rbs
    def restore_entries: (String str, singleton(LibraryEntry) klass) -> ::Array[LibraryEntry]
                       | (String str, singleton(ClassEntry) klass) -> ::Array[ClassEntry]
                       | (String str, singleton(MethodEntry) klass) -> ::Array[MethodEntry]
```

にしてしまうと

```ruby
    def restore_entries(str, klass)
      return [] if str.nil?
      str.split(',').map {|id| klass.load(@db, id) }
    end
```

の返り値の型が `Array[LibraryEntry | ClassEntry | MethodEntry]` になってしまってうまくいかないので、

```rbs
    # klass < Entry, Array[klass]
    def restore_entries: (String str, untyped klass) -> ::Array[untyped]
```

のように `untyped` のままにするしかなさそうだった。

### lib/bitclust/preprocessor.rb

`key?` でチェックしてから参照するパターンに `# steep:ignore` を追加した。
インスタンス変数だからダメというわけではなく、ローカル変数に代入するように書き換えてもダメそうだった。

```ruby
      if t = s.scan(/\w+/)
        unless @params.key?(t) # steep:ignore
          scan_error "database property `#{t}' not exist"
        end
        @params[t] # steep:ignore
```

### lib/bitclust/subcommands/htmlfile_command.rb

<https://github.com/rurema/bitclust/blob/2a2028ac761cee63a27eb24f7b6673da4b9fbd3e/lib/bitclust/subcommands/htmlfile_command.rb#L48> のように途中で変数名を再利用してるときに `# @type var options: 以下の部分の型` と書くとコメント行より上の `options` にも影響してしまってダメだったけど、行末に `#:  新しい型` なら大丈夫そうだった。

### lib/bitclust/database.rb

`properties` まわりの型を厳密にしようとしたが、 `load_properties('properties')` で `db-x.y/properties` を読むときは厳密にできても、
`entry.rb` で `@db.load_properties(objpath())` と呼ばれている方はここでは厳密にできなくて、
`propget` や `propset` も `bitclust init` サブコマンド自体では制限していなくて `version` と `encoding` 以外も指定できてしまうため、
緩くしていたらこういう状態になってしまった。

`database.rb` の内部で `entry.rb` 用に `'source'` に値を設定して、
`properties` では消しているのも `database_propkey` に足さないと型エラーになるところがあって困ってしまったので、
足したままにしている。

```rbs
    type propkey_type = ::String
    type properties_type = ::Hash[propkey_type, String]

    # 'source' is internal use only
    type database_propkey = 'version' | 'encoding' | 'source'
    type database_properties = Hash[database_propkey, String]

# ...

    def properties: () -> database_properties

    def propkeys: () -> ::Array[propkey_type]

    # accept propkey_type, but should not happen
    def propget: (database_propkey key) -> String
               | (propkey_type key) -> String?

    # accept propkey_type, but should not happen
    def propset: (database_propkey key, String value) -> void
               | (propkey_type key, String value) -> void

# ...

    def load_properties: ('properties' rel) -> database_properties
                       | (::String rel) -> properties_type
```

### lib/bitclust/rdcompiler.rb

これらが未使用だったので削除した。

```ruby
      @library = nil
      @class = nil
```

### Hash[Symbol, untyped]

できるだけ Record に変更して減らし中。

### chm_command.rbs

FIXME: `**` がないのは `chm_command.rb` に合わせているため。

```diff
-        def method_missing: (untyped name, *untyped args) { (?) -> untyped } -> untyped
+        def method_missing: (Symbol name, *untyped args) { (?) -> untyped } -> untyped
```

### searcher.rbs

FIXME: 今だとキーワード引数にする方が良さそう。

```diff
-    def initialize: (Plain compiler, Hash[Symbol, untyped] opts) -> void
+    def initialize: (Plain compiler, { :describe_all => bool, :line => bool, :encoding => String? } opts) -> void
```
