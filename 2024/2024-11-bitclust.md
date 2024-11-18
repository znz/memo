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
