# bitclust 作業メモ

## chm_command.rbs

`method_missing` で delegate しているメソッドの型について良い方法がなさそうなので、結局コピーした。

## extract_command.rbs

特にひっかかるところはなかった。

## htmlfile_command.rbs

`functionreferenceparser.rbs` の型付けも必要になった。

`lineinput.rbs` の `alias` を `sig/prototype/bitclust/lineinput.rbs` に残していたのが未定義になっていたので、
`sig/hand-written/bitclust/lineinput.rbs` に移動した。

`FunctionHeader` が `Struct` なのでとりあえず `attr_accessor` を並べて、
無引数の `new` を使っていたので、
それを許可するために `self.new` に `| ...` を使って無引数の `() -> instance` を追加した。

```rbs
  class FunctionHeader < Struct[untyped]
    attr_accessor macro: bool
    attr_accessor private: bool
    attr_accessor type: String
    attr_accessor name: String
    attr_accessor params: String?

    def self.new: () -> instance
                | ...
  end
```

`FunctionEntry` に代入しているところがあったので、
`def` で reader だけ定義していたのを `attr_accessor` に変更した。
`name` だけは `RBS::DuplicatedMethodDefinition` になるので `attr_writer` にしておいた。

```diff
-    def filename: () ->        String
-    def macro: () ->           bool
-    def private: () ->         bool
-    def type: () ->            String
-    def params: () ->          String
-    def source: () ->          String
-    def source_location: () -> Location
+    attr_accessor filename: String
+    attr_accessor macro: bool
+    attr_accessor private: bool
+    attr_accessor type: String
+    attr_writer name: String
+    attr_accessor params: String
+    attr_accessor source: String
+    attr_accessor source_location: Location
```

## chm_command.rb の型エラー対策

`encode('windows-31j', { :fallback => FIX_UNDEF } )` には `encode('windows-31j', **{ :fallback => FIX_UNDEF } )` のように `**` をつけた。

以下の `entry_screen` で `Screen#body` がないというのは、結局 `Screen` に `def body: () -> String` を足して、 `TemplateScreen` に `undef body` を入れたかったが書き方がわからなかったので、 `def body: () -> bot` を入れておくことにして型エラーを消した。

```ruby
        html = manager.entry_screen(entry, {:database => db}).body
        e = entry.is_a?(Array) ? entry.sort.first : entry
```

## server_command.rbs

app.rbs も関連している。

`BitClust::App` は `WEBrick::HTTPServer#mount` に渡しているが、 `WEBrick::HTTPServlet::AbstractServlet` を継承していないので、型エラーになってしまった。

とりあえず以下のような interface を追加して回避することにした。
`webrick` に入れるかどうかは検討中。

`def get_instance(server)` だと `get_instance: (HTTPServer, *untyped options)` と合わないようなので、
`def get_instance(_server, *_)` にしてみたが、後で戻すかも。

```rbs
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
             | ...
  end
end
```
