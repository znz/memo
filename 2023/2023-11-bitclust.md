# bitclust 作業メモ

## rbs 作業再開

[Asakusa-bashi.rbs 第1回 オンライン開催](https://connpass.com/event/301065/) に参加して作業。

久しぶりに https://github.com/znz/bitclust/tree/add-rbs の作業を再開しようと思って、rbs や steep を最新にして bundle exec steep validate を動かしてみたら、

```
Calling `DidYouMean::SPELL_CHECKERS.merge!(error_name => spell_checker)' has been deprecated. Please call DidYouMean.correct_error(error_name, spell_checker)' instead.
```

が最初に出る、

```
.../rbenv/versions/3.2.2/lib/ruby/3.2.0/uri/version.rb:3: warning: already initialized constant URI::VERSION_CODE
.../rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/uri-0.12.2/lib/uri/version.rb:3: warning: previous definition of VERSION_CODE was here
```

のようなのが大量に出る、
`Diagnostic ID: RBS::DuplicatedDeclaration` が <https://github.com/znz/bitclust/blob/15fc63e64642fba4aaa8313ea5a0928ed98c8684/sig/prototype/bitclust/syntax_highlighter.rbs#L13> とかで大量に出る、
ということが起きて原因がよくわからなかった。

`uri` のは `gem "uri"` を `Gemfile` に追加したらおさまった。(`pathname` でも出たのでそれも追加した。)

1つ目は `bundler` を更新すれば良いと教えてもらって `bundle update --bundler` で解決。

```
sig/prototype/bitclust/subcommands/setup_command.rbs:16:6: [error] Declaration of `::BitClust::Subcommands::SetupCommand::REPOSITORY_PATH` is duplicated
│ Diagnostic ID: RBS::DuplicatedDeclaration
│
└       REPOSITORY_PATH: "https://github.com/rurema/doctree.git"
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sig/prototype/bitclust/syntax_highlighter.rbs:13:4: [error] Declaration of `::BitClust::SyntaxHighlighter::LABELS` is duplicated
│ Diagnostic ID: RBS::DuplicatedDeclaration
│
└     LABELS: ::Hash[untyped, untyped]
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

のようなのが大量に出ていたのは、結局勘で [`Steepfile` の `signature "sig"` をコメントアウト](https://github.com/rurema/bitclust/commit/15fc63e64642fba4aaa8313ea5a0928ed98c8684) したら解決した。

## methodid.rb

* `lib/bitclust/methodid.rb` の `(not @library or m.library.name?(@library))` などで `nil` の可能性が指摘されていたので、とりあえず `|| raise` を追加。
* その変更を受けて `BitClust::MethodEntry#name?` の引数が `untyped` だったのを `String` に変更。この変更で他の場所で型エラーが増える可能性はありそう。
* `BitClust::MethodNamePattern#expand_ic` は定義されていなくて、 `include` などもなかったので、コメントアウトして `raise "[MAYBE BUG] BitClust::MethodNamePattern#expand_ic is not defined"` に書き換え。
