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
