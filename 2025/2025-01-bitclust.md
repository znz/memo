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
