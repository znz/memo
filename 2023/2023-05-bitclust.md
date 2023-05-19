# bitclust 作業メモ

## rbs 導入したい 1日目

- <https://speakerdeck.com/pocke/lets-write-rbs?slide=32> を参考に、と思ったら実際のデモで使われていたコマンドラインがわからなかった。
- <https://github.com/ruby/rbs> をみても手元のアプリで使ってみたい人がどこを見にいけばいいのかという情報がみつけられなかった。
- <https://zenn.dev/leaner_dev/articles/20210915-rubykaigi-2021-rbs-collection#rbs-collection-%E3%81%AE%E8%A8%AD%E5%AE%9A> を参考にして、<https://github.com/ruby/rbs/blob/master/docs/collection.md> が最初にする手順ということがわかった。
- とりあえず `Gemfile` には足さずにグローバルに `gem install` して試す方針
- `ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin22]` で `gem update` して `rbs` などを最新にした。

```console
% rbs collection init
created: rbs_collection.yaml
% cat rbs_collection.yaml
# Download sources
sources:
  - type: git
    name: ruby/gem_rbs_collection
    remote: https://github.com/ruby/gem_rbs_collection.git
    revision: main
    repo_dir: gems

# You can specify local directories as sources also.
# - type: local
#   path: path/to/your/local/repository

# A directory to install the downloaded RBSs
path: .gem_rbs_collection

gems:
  # Skip loading rbs gem's RBS.
  # It's unnecessary if you don't use rbs as a library.
  - name: rbs
    ignore: true
% rbs collection install
Using cgi:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/cgi/0)
Installing rack:2.2 (rack@d0d7aeed98f)
Using tempfile:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/tempfile/0)
Using uri:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/uri/0)
It's done! 4 gems' RBSs now installed.
% echo /.gem_rbs_collection/ >> .gitignore
```

`rbs_collection.yaml` に追加:

```yaml
  - name: progressbar
  - name: webrick
  - name: test-unit
  - name: test-unit-notify
  - name: test-unit-rr
```

最初に `ansible` の癖なのか `name` だけだからと `name:` をつけ忘れていたら、以下のようにわかりにくいエラーになっていた。

```text
/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/lib/rbs/collection/config/lockfile_generator.rb:64:in `block in generate': undefined method `dig' for "progressbar":String (NoMethodError)

            if Sources::Stdlib.instance.has?(gem["name"], nil) || gem.dig("source", "type") == "stdlib"
                                                                     ^^^^
```

- `gem i steep` で `steep` をグローバルに入れた。
- `steep init` で `Steepfile` を作成して編集した。
- `rbs prototype rb --out-dir=sig lib` の前後に `steep check` でチェックした。


```console
% steep init
Writing Steepfile...
% cat Steepfile
# D = Steep::Diagnostic
#
# target :lib do
#   signature "sig"
#
#   check "lib"                       # Directory name
#   check "Gemfile"                   # File name
#   check "app/models/**/*.rb"        # Glob
#   # ignore "lib/templates/*.rb"
#
#   # library "pathname", "set"       # Standard libraries
#   # library "strong_json"           # Gems
#
#   # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
#   # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
#   # configure_code_diagnostics do |hash|             # You can setup everything yourself
#   #   hash[D::Ruby::NoMethod] = :information
#   # end
# end

# target :test do
#   signature "sig", "sig-private"
#
#   check "test"
#
#   # library "pathname", "set"       # Standard libraries
# end
% vi Steepfile
% cat Steepfile
target :lib do
  signature "sig"

  check "lib"
  check "Gemfile"
end
% steep check
(省略)
Detected 2582 problems from 59 files
% rbs prototype rb --out-dir=sig lib
(省略)
% steep check
# Type checking files:

.........................................F.........................................F................F.........F..............................................

sig/bitclust/server.rbs:18:4: [error] Cannot find type `DRb::DRbUndumped`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     include DRb::DRbUndumped
      ~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/server.rbs:10:4: [error] Cannot find type `DRb::DRbUndumped`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     include DRb::DRbUndumped
      ~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/server.rbs:14:4: [error] Cannot find type `DRb::DRbUndumped`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     include DRb::DRbUndumped
      ~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/subcommands/chm_command.rbs:18:10: [error] Cannot find type `ERB::Util`
│ Diagnostic ID: RBS::UnknownTypeName
│
└           include ERB::Util
            ~~~~~~~~~~~~~~~~~

sig/bitclust/interface.rbs:20:4: [error] Cannot find type `::WEBrick::CGI`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     class CGI < ::WEBrick::CGI
      ~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/interface.rbs:32:4: [error] Cannot find type `::WEBrick::HTTPServlet::AbstractServlet`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     class WEBrickServlet < ::WEBrick::HTTPServlet::AbstractServlet
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/syntax_highlighter.rbs:2:2: [error] Cannot find type `Ripper::Filter`
│ Diagnostic ID: RBS::UnknownTypeName
│
└   class SyntaxHighlighter < Ripper::Filter
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Detected 7 problems from 4 files
```

- `rbs_collection.yaml` に追加すると、またわかりにくいエラーが発生した。
- 順番にコメントアウトすると `drb` が原因だった。
- 確認すると <https://github.com/ruby/rbs/tree/master/stdlib> に `drb` がなかった。

```console
% vi rbs_collection.yaml
% cat rbs_collection.yaml
# Download sources
sources:
  - type: git
    name: ruby/gem_rbs_collection
    remote: https://github.com/ruby/gem_rbs_collection.git
    revision: main
    repo_dir: gems

# You can specify local directories as sources also.
# - type: local
#   path: path/to/your/local/repository

# A directory to install the downloaded RBSs
path: .gem_rbs_collection

gems:
  # Skip loading rbs gem's RBS.
  # It's unnecessary if you don't use rbs as a library.
  - name: rbs
    ignore: true

  - name: drb
  - name: erb
  - name: ripper

  - name: progressbar
  - name: webrick
  - name: test-unit
  - name: test-unit-notify
  - name: test-unit-rr
% rbs collection update
/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/lib/rbs/collection/config/lockfile_generator.rb:136:in `assign_gem': undefined method `dependencies' for nil:NilClass (NoMethodError)

          gem_hash[name].dependencies.each do |dep|
                        ^^^^^^^^^^^^^
```

- `- name: drb` をコメントアウトして続き。

```console
% rbs collection update
Using cgi:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/cgi/0)
Using erb:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/erb/0)
Using rack:2.2 (rack@d0d7aeed98f)
Using ripper:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/ripper/0)
Using tempfile:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/tempfile/0)
Using uri:0 (/Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/stdlib/uri/0)
It's done! 6 gems' RBSs now installed.
% steep check
# Type checking files:

........................................................................F...................................................................................F..

sig/bitclust/interface.rbs:20:4: [error] Cannot find type `::WEBrick::CGI`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     class CGI < ::WEBrick::CGI
      ~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/interface.rbs:32:4: [error] Cannot find type `::WEBrick::HTTPServlet::AbstractServlet`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     class WEBrickServlet < ::WEBrick::HTTPServlet::AbstractServlet
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/server.rbs:18:4: [error] Cannot find type `DRb::DRbUndumped`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     include DRb::DRbUndumped
      ~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/server.rbs:10:4: [error] Cannot find type `DRb::DRbUndumped`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     include DRb::DRbUndumped
      ~~~~~~~~~~~~~~~~~~~~~~~~

sig/bitclust/server.rbs:14:4: [error] Cannot find type `DRb::DRbUndumped`
│ Diagnostic ID: RBS::UnknownTypeName
│
└     include DRb::DRbUndumped
      ~~~~~~~~~~~~~~~~~~~~~~~~

Detected 5 problems from 2 files
```

## rbs 導入したい 2日目

### manifest.yaml

- <https://github.com/ruby/rbs/blob/master/docs/collection.md#manifestyaml> をみて `manifest.yaml` を用意してみた。
- 読まれているか確認するために `rbs_collection.yaml` の `- name: erb` をコメントアウトして以下の内容のファイルを用意した。

```yaml
dependencies:
  - name: erb
```

- `manifest.yaml` に置いても `sig/manifest.yaml` に置いても `rbs collection update` で `rbs_collection.lock.yaml` の `erb` が消えたままだったので、読まれてなさそうだった。
- `gem` としてインストールしたときの話なのかなと思って、とりあえず `manifest.yaml` は消した。

### VSCode で拡張をインストール

- 以下の拡張機能をインストール
  - `soutaro.steep-vscode`
  - `soutaro.rbs-syntax`
  - `mame.ruby-typeprof`

- `Gemfile` に以下を追加して `bundle update` (後で `gem "typeprof", require: false` は消した)

```ruby
gem "steep", require: false
gem "typeprof", require: false
```

- `rbs_collection.yaml` に以下を追加

```yaml
  - name: steep
    ignore: true
```

- `bundle update` 前に拡張機能のインストールをしたので `steep` や `typeprof` の server の起動に失敗していたので、 VSCode を再起動
- `sig/bitclust/subcommands/chm_command.rbs` の `include ERB::Util` に赤い波線がつくようになった。
- `TypeProf` は以下のエラーで起動に失敗していたが、よくわからないので一旦 `mame.ruby-typeprof` はアンインストールした。

```text
[vscode] Ruby TypeProf is running
[Info  - XX:XX:XX] bundler: failed to load command: typeprof (/Users/kazu/.anyenv/envs/rbenv/versions/3.2/bin/typeprof)
[Info  - XX:XX:XX] Connection to server got closed. Server will restart.
[Info  - XX:XX:XX] /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/typeprof-0.21.7/lib/typeprof/import.rb:34:in `[]': no implicit conversion of String into Integer (TypeError)
[Info  - XX:XX:XX]
[Info  - XX:XX:XX]             collection_lock.gems.each {|gem| @loaded_gems << gem["name"] }
[Info  - XX:XX:XX]                                                                  ^^^^^^
```

### steep check の error 対策開始

- <https://speakerdeck.com/pocke/lets-write-rbs?slide=16> の方法を試すため、 `sig` を一度削除して作りなおし。
- `--base-dir=.` をつけると `sig/prototype/lib/bitclust` になるようだったが、 `lib` はいらないので省略して `sig/prototype/bitclust` ができた。

```console
%  rm -rf sig
% rbs prototype rb --out-dir=sig/prototype lib
Processing `lib`...
  Generating RBS for `lib/bitclust/app.rb`...
    - Writing RBS to `sig/prototype/bitclust/app.rbs`...
(略)
  Generating RBS for `lib/bitclust/version.rb`...
    - Writing RBS to `sig/prototype/bitclust/version.rbs`...
  Generating RBS for `lib/bitclust.rb`...
    - Writing RBS to `sig/prototype/bitclust.rbs`...
```

### sig/hand-written 1st try

- とりあえず `steep check` で `RBS::UnknownTypeName` になるモジュールとクラスを用意した。

```console
% cat sig/hand-written/drb.rbs
module DRb::DRbUndumped
end
% cat sig/hand-written/webrick.rbs
4class WEBrick::CGI
end

class WEBrick::HTTPServlet::AbstractServlet
end
```

- すると逆にエラーが増えた。

```console
% steep check
# Type checking files:

........................F....[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)] Unexpected error: RuntimeError
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/lib/rbs/resolver/constant_resolver.rb:25:in `block in initialize'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/lib/rbs/resolver/constant_resolver.rb:20:in `each'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/lib/rbs/resolver/constant_resolver.rb:20:in `initialize'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/lib/rbs/resolver/constant_resolver.rb:90:in `new'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/lib/rbs/resolver/constant_resolver.rb:90:in `initialize'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/signature_service.rb:74:in `new'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/signature_service.rb:74:in `constant_resolver'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/signature_service.rb:141:in `latest_constant_resolver'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:283:in `block (3 levels) in typecheck_source'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:329:in `block in type_check_file'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:99:in `block in tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:37:in `tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:99:in `tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:327:in `type_check_file'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:283:in `block (2 levels) in typecheck_source'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep.rb:178:in `measure'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:277:in `block in typecheck_source'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:99:in `block in tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:37:in `tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:99:in `tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:276:in `typecheck_source'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/server/type_check_worker.rb:184:in `handle_job'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/server/base_worker.rb:54:in `block (2 levels) in run'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:99:in `block in tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:37:in `tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/tagged_logging.rb:99:in `tagged'
[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/classentry.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/server/base_worker.rb:44:in `block in run'
................[Steep 1.4.0] [typecheck:typecheck@0] [background] [#typecheck_source(path=lib/bitclust/generators/epub.rb)] Unexpected error: RuntimeError
(略)
[Steep 1.4.0] [typecheck:typecheck@8] [background] [#typecheck_source(path=lib/bitclust/subcommands/query_command.rb)]   /Users/kazu/.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/steep-1.4.0/lib/steep/server/base_worker.rb:44:in `block in run'
...

../../../../.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/core/string.rbs:1041:2: [error] Non-overloading method definition of `bytesize` in `::String` cannot be duplicated
│ Diagnostic ID: RBS::DuplicatedMethodDefinition
│
└   def bytesize: () -> Integer
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/classentry.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class ClassEntry < Entry
    ~~~~~~~~~~~~~~~~~~~~~~~~

sig/hand-written/webrick.rbs:1:0: [error] Cannot find type `::WEBrick`
│ Diagnostic ID: RBS::UnknownTypeName
│
└ class WEBrick::CGI
  ~~~~~~~~~~~~~~~~~~

sig/hand-written/webrick.rbs:4:0: [error] Cannot find type `::WEBrick::HTTPServlet`
│ Diagnostic ID: RBS::UnknownTypeName
│
└ class WEBrick::HTTPServlet::AbstractServlet
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/hand-written/drb.rbs:1:0: [error] Cannot find type `::DRb`
│ Diagnostic ID: RBS::UnknownTypeName
│
└ module DRb::DRbUndumped
  ~~~~~~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/server.rbs:26:0: [error] Cannot find type `::DRb`
│ Diagnostic ID: RBS::UnknownTypeName
│
└ class DRb::DRbObject
  ~~~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/functionentry.rbs:19:4: [error] Cannot find the original method `macro` in `::BitClust::FunctionEntry`
│ Diagnostic ID: RBS::UnknownMethodAlias
│
└     alias macro? macro
      ~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/preprocessor.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class LineFilter
    ~~~~~~~~~~~~~~~~

sig/prototype/bitclust/libraryentry.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class LibraryEntry < Entry
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/subcommands/chm_command.rbs:15:8: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└         class Content
          ~~~~~~~~~~~~~

Detected 10 problems from 9 files
```

### sig/hand-written 2nd try

- `steep check` のエラーをみつつ、以下のように調整した。

```console
% cat sig/hand-written/drb.rbs
module DRb
  module DRbUndumped
  end
end
% cat sig/hand-written/webrick.rbs
module WEBrick
  class CGI
  end

  module HTTPServlet
    class AbstractServlet
    end
  end
end
```

- `lib/bitclust/compat.rb` が問題をおこしてそうだった。

```console
% steep check
# Type checking files:

...............................F................F..........F.FF....F..F..F.FF......FF..F.F..F....FF........FF.....FFFFFFFFF.F.FFF...FF...F......F......F...FF.F.F...F[Steep 1.4.0] [typecheck:typecheck@5] [background] [#typecheck_source(path=lib/bitclust/lineinput.rb)] [#type_check_file(lib/bitclust/lineinput.rb@lib)] [synthesize:(12:1)] [synthesize:(16:1)] [synthesize:(18:3)] [synthesize:(54:3)] [synthesize:(55:5)] [synthesize:(55:5)] [synthesize:(56:7)] [synthesize:(58:7)] or_asgn with csend lhs is not supported
[Steep 1.4.0] [typecheck:typecheck@5] [background] [#typecheck_source(path=lib/bitclust/lineinput.rb)] [#type_check_file(lib/bitclust/lineinput.rb@lib)] [synthesize:(12:1)] [synthesize:(16:1)] [synthesize:(18:3)] [synthesize:(54:3)] [synthesize:(55:5)] [synthesize:(65:5)] or_asgn with csend lhs is not supported
FFF.F...F..FF.F.F.F........FF...F.FFF....F.....F..FFFF..

../../../../.anyenv/envs/rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/rbs-3.1.0/core/string.rbs:1041:2: [error] Non-overloading method definition of `bytesize` in `::String` cannot be duplicated
│ Diagnostic ID: RBS::DuplicatedMethodDefinition
│
└   def bytesize: () -> Integer
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~

lib/bitclust/completion.rb:11:0: [error] UnexpectedError: sig/prototype/bitclust/compat.rbs:2:2...2:23: Unknown method alias name: __send__ => __send (::BitClust)
│ Diagnostic ID: Ruby::UnexpectedError
│
└ module BitClust
  ~~~~~~~~~~~~~~~

(略)

Detected 126 problems from 64 files
```

- `sig/prototype/bitclust/compat.rbs` を消すとエラーが減った。

```console
% rm sig/prototype/bitclust/compat.rbs
% steep check
```

### steep validate に切り替え

- `steep -h` でサブコマンド一覧をみて試してみると `steep validate` で `rbs` ファイルだけのチェックができた。

```console
% steep validate
sig/prototype/bitclust/classentry.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class ClassEntry < Entry
    ~~~~~~~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/functionentry.rbs:19:4: [error] Cannot find the original method `macro` in `::BitClust::FunctionEntry`
│ Diagnostic ID: RBS::UnknownMethodAlias
│
└     alias macro? macro
      ~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/libraryentry.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class LibraryEntry < Entry
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

sig/prototype/bitclust/preprocessor.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class LineFilter
    ~~~~~~~~~~~~~~~~

sig/prototype/bitclust/preprocessor.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class LineFilter
    ~~~~~~~~~~~~~~~~

sig/prototype/bitclust/preprocessor.rbs:3:2: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└   class LineFilter
    ~~~~~~~~~~~~~~~~

sig/prototype/bitclust/subcommands/chm_command.rbs:15:8: [error] Type `::Enumerable` is generic but used as a non generic type
│ Diagnostic ID: RBS::InvalidTypeApplication
│
└         class Content
          ~~~~~~~~~~~~~
```

### Enumerable の調整

- `BitClust::ClassEntry#each` の実装をながめて、 `BitClust::MethodEntry` だと判断して埋めた。
- `BitClust::LibraryEntry#each` と見間違えて `BitClust::LibraryEntry#each_class` と `BitClust::LibraryEntry#each_method` を調べたので、それも書いておいた。
- `BitClust::LibraryEntry#each` がなくて `include Enumerable` の generic を解決できないとわかったので、 `lib/bitclust/libraryentry.rb` の `include Enumerable` を消した。

```console
% ruby -I lib -r bitclust -e 'p BitClust::LibraryEntry.instance_methods.grep(/each/)'
[:each_class, :each_method]
% ruby -I lib -r bitclust -e 'p BitClust::ClassEntry.instance_methods.grep(/each/)'
[:each, :each_cons, :each_with_object, :each_with_index, :reverse_each, :each_entry, :each_slice]
% cat sig/hand-written/bitclust/classentry.rbs
module BitClust
  class ClassEntry < Entry
    include Enumerable[MethodEntry]
    def each: () { (MethodEntry) -> untyped } -> untyped
  end
end
% cat sig/hand-written/bitclust/libraryentry.rbs
module BitClust
  class LibraryEntry < Entry
    def each_class: () { (ClassEntry) -> untyped } -> untyped
    def each_method: () { (MethodEntry) -> untyped } -> untyped
  end
end
```

再生成した。

```console
% rm -r sig/prototype
% rbs prototype rb --out-dir=sig/prototype lib
(略)
% rm sig/prototype/bitclust/compat.rbs
% rbs subtract --write sig/prototype sig/hand-written
% steep validate
(略)
```

### persistent_properties の対応

- `alias macro? macro` の原因をみてみると `persistent_properties` の `property` で定義されるメソッドだったので、とりあえず `BitClust::FunctionEntry` だけ対応した。
- `name` は `remove_method :name` と `alias name id` で上書きされていて `RBS::DuplicatedMethodDefinition` になるので消した。

```console
% cat sig/hand-written/bitclust/functionentry.rbs
module BitClust
  class FunctionEntry < Entry
    def filename: () ->        String
    def macro: () ->           bool
    def private: () ->         bool
    def type: () ->            String
    def params: () ->          String
    def source: () ->          String
    def source_location: () -> Location
  end
end
```

### Enumerable の調整の続き

- `BitClust::LineFilter#each` はたぶん `String` ということにした。間違っていれば後でわかるはず。
- `BitClust::Subcommands::ChmCommand::Sitemap::Content#each` は `BitClust::Subcommands::ChmCommand::Sitemap::Content` が入りそうに見えたが、確信がもてず、 `chm` 生成は動作確認もなかなかできなさそうなので、 `untyped` にした。
- これで `steep validate` のエラーはなくなった。

```console
% cat sig/hand-written/bitclust/preprocessor.rbs
module BitClust
  class LineFilter
    include Enumerable[String]

    def each: () { (String) -> untyped } -> untyped
  end
end
% rbs subtract --write sig/prototype sig/hand-written
% steep validate
(略)
% cat sig/hand-written/bitclust/subcommands/chm_command.rbs
module BitClust
  module Subcommands
    class ChmCommand < Subcommand
      class Sitemap
        class Content
          include Enumerable[untyped]
          def each: () { (untyped) -> untyped } -> untyped
        end
      end
    end
  end
end
% rbs subtract --write sig/prototype sig/hand-written
% steep validate
```

### steep check のエラー確認

- VSCode 上でいくつか赤くなっているファイルのうち、 `textutils.rb` をみてみると `gsub` のブロックの中の `$~` が `(::MatchData | nil)` だと言われてしまっているが、 `nil` の可能性はなさそうな気がする。
- 今日はここまで。

```console
%  steep check lib/bitclust/textutils.rb
# Type checking files:

............................................................................................................F.........................................................

lib/bitclust/textutils.rb:21:23: [error] Type `(::MatchData | nil)` does not have method `begin`
│ Diagnostic ID: Ruby::NoMethod
│
└         len = ts - ($~.begin(0) + add) % ts
                         ~~~~~

Detected 1 problem from 1 file
```

## rbs 導入したい 3日目

- vscode でみながら `sig/hand-written` にコピーして更新して以下のタスクで重複を消して調整していた。

<https://github.com/znz/bitclust/blob/add-rbs/Rakefile#LL18C1-L26C1>

```ruby
desc "Re-generate sig/prototype"
task :sig do
  FileUtils.rm_rf 'sig/prototype'
  sh 'rbs prototype rb --out-dir=sig/prototype lib'
  FileUtils.rm 'sig/prototype/bitclust/compat.rbs'
  sh 'rbs subtract --write sig/prototype sig/hand-written'
  sh 'steep validate'
end
```

- 現状は <https://github.com/znz/bitclust/tree/add-rbs> に push した。
- `gsub` のブロックの中の `$~` などのように `nil` にならないとわかっている部分で `nil` の可能性の型エラーになるのをどうすればいいのかがまだわからない。
- `@input.path if @input.respond_to?(:path)` のように `respond_to?` で分岐している部分で `path` メソッドのない型も通すのはどうすればいいのかがまだわからない。

## rbs 導入したい 4日目

- 他への依存が少なそうなものから再開。
- `bitclust/subcommand.rbs` は `rbs_collection.yaml` に `optparse` と `pathname` の追加が必要だった。
- `bitclust/syntax_highlighter.rbs` は `event_name = event.to_s.sub(/\Aon_/, "")   # :on_event --> "event"` というコメントが [型アサーション](https://github.com/soutaro/steep/blob/master/guides/src/nil-optional/nil-optional.md#type-assertions) に誤認識されていた。
- `rb` ファイルは潜在バグ修正だけで、型のための修正は (まだ) しない方針なので、そのまま。
- 昨日までの変更で、型のために `return foo, bar` のようなものを `[foo, bar]` のように書き換えてしまったところがあるので、あとで戻すかも。
- `bitclust/rrdparser.rbs` は多かったので `Context` は後回しにして他をやっていた。
- `bitclust/compat.rbs` は削除していたが、 `fopen` は使われているので、 `File.open` をホバーしたときに出てくる型をコピーして使った。
- `NameUtils` の `typemark2name` に正常系でも `nil` を渡す可能性があったので、 `def self?.typemark2name: (String? mark) -> Symbol` に変更した。
- `lib/bitclust/rrdparser.rb` の `nil` の可能性があるいくつかは潜在バグの可能性があるので、 `&.` にしたり `compact` をつけたりした。
