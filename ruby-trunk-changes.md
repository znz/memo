あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。

# 2019-04-25

## [c9715eb494](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190425#c9715eb494)

- コピー元の `ext/bigdecimal/lib/bigdecimal/*.rb` のパーミッションをみたかったのに、 `ls -laR ext/bigdecimal` だと表示する場所がソースディレクトリではなくビルドディレクトリになっていて単純に間違っていたので、ソースディレクトリの方も追加したというコミット。
- git status もソースディレクトリで実行したかったので cd 追加。
- 参考: <https://travis-ci.org/ruby/ruby/builds/524397485>

# 2019-04-24

## [2ef6673708](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190425#2ef6673708)

- 環境によっては ~git rev-parse --short HEAD~ が10文字に満たなくて、短くなる (7文字とか) ことがある (git のバージョンが古いとき?) ようなので、そういう環境でも10文字になるようにしているようです。

## 2019-04-23

- `RUBY_REVISION` が整数から文字列に変わるのはまずいんじゃないかという話もあったみたいだけど、このままなのかなあ。

## [f005ccc771](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#f005ccc771)

- [ ] `[ruby-core:91650] [Misc #15630]` がリンクになってない
- [ ] rurema に影響する?

## [87261cf59f](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#87261cf59f)

- ローカルでのコミットがあると `ruby -v` などで `last_commit=RUBY_LAST_COMMIT_TITLE` が出るようになっているのですが、[直前のコミット](https://github.com/ruby/ruby/commit/5da52d1210625fb00acd573b3f32281b4bde1730)でローカルのコミットがなくても出るようになっていたので、元の挙動に戻したつもり。

## [8c689e216f](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#8c689e216f)

- pull request で approved がついているものをみて fork と branch を確認して `git pull https://github.com/sos4nt/ruby patch-5` して取り込んだマージコミット。
- その後、周辺ツールなどの問題もあり、現状はマージコミット禁止 (hook でチェックもしている) ということに。議論の余地ありということで、今後どうなるかは未定。
- Fix GH-XXXX は Fix https://github.com/ruby/ruby/pull/2084 のように URL で書く方が良さそうです。

## [6fbf4e22c8](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#6fbf4e22c8)

- マークアップ削除があって conflict して機械的にマージできなかったので、文章だけもらって Fix と Co-authored-by をつけたコミット。
- Co-authored-by がきいていたので、それに目をつけて svn から git に移行したというのを発見した人がいたような。 (svn から git-svn 経由で git にミラーされていると git-svn-id: が追加される位置の関係で Co-authored-by がきかなかった)
- <https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#6fbf4e22c8> には pull request へのリンクがない?

## [4946c3e4b5](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#4946c3e4b5)

- `.gitattributes` をみて、そんなのがあるんだ、と思って `file tool/* | grep Ruby | grep -v '.rb'` のような感じで雑に調べて、抜けていたのを追加した感じ。

## [2ae5f6f97c](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#2ae5f6f97c)

- [ ] dcommmit は m が多い
