- あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。
- <https://ruby-trunk-changes.hatenablog.com> typo 指摘などは *hatenablog* をつけることにしました。
- [rurema](https://github.com/rurema/doctree) 用のメモには *rurema* をつけることにしました。

# 2019-04-25

## [c9715eb494](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190425#c9715eb494)

- コピー元の `ext/bigdecimal/lib/bigdecimal/*.rb` のパーミッションをみたかったのに、 `ls -laR ext/bigdecimal` だと表示する場所がソースディレクトリではなくビルドディレクトリになっていて単純に間違っていたので、ソースディレクトリの方も追加したというコミット。
- git status もソースディレクトリで実行したかったので cd 追加。
- 参考: <https://travis-ci.org/ruby/ruby/builds/524397485>

# 2019-04-24

## [2ef6673708](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190425#2ef6673708)

- 環境によっては ~git rev-parse --short HEAD~ が10文字に満たなくて、短くなる (7文字とか) ことがある (git のバージョンが古いとき?) ようなので、そういう環境でも10文字になるようにしているようです。

# 2019-04-23

- `RUBY_REVISION` が整数から文字列に変わるのはまずいんじゃないかという話もあったみたいだけど、このままなのかなあ。

## [f005ccc771](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190423#f005ccc771)

- [ ] *hatenablog* `[ruby-core:91650] [Misc #15630]` がリンクになってない
- [ ] *rurema* 要影響確認

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

- [ ] *hatenablog* dcommmit は m が多い

# 2019-04-21

ChangeLog 対応が削られてて、もうないのかなと思って確認したらリリース tarball には入っていたので、リリース時に生成するのはまだやっているようです。

## [r67676](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67650_67693#r67676)

日本の VPS からだと

```
$ time git ls-remote https://github.com/ruby/ruby.git > /dev/null

real    0m1.893s
user    0m0.136s
sys     0m0.108s
$ time git ls-remote https://git.ruby-lang.org/ruby.git > /dev/null

real    0m0.422s
user    0m0.076s
sys     0m0.044s
```

という感じの速度で、カナダの VPS からだと

```
# time git ls-remote https://git.ruby-lang.org/ruby.git > /dev/null

real    0m1.555s
user    0m0.081s
sys 0m0.054s
# time git ls-remote https://github.com/ruby/ruby.git > /dev/null

real    0m0.492s
user    0m0.086s
sys     0m0.068s
```

という感じで github と速度が逆転する感じだったので、少なくとも北米からだと github.com の方が速いと思います。
アジア圏からだとどうなのかは不明です。

# 2019-04-20

## [Time#floor](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67619_67649#r67632)

- [ ] *rurema* Add `Time#floor`

# 2019-04-19

## [r67606](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67606_67618#r67606)

- [ ] *rurema* `io.c: warn non-nil $,`

## [r67613](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67606_67618#r67613)

- [ ] *rurema* `time.c: added in: option to Time.now`

# 2019-04-18

## [r67603](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67601_67605#r67603)

- [ ] *rurema* `string.c: warn non-nil $;`

# 2019-04-17

- パターンマッチが入ったけど、テストであったようにたくさん使うと大量の警告が出るので、実際に使おうとする人がどうするのかが気になります。 `require 'continuation'` のように最初だけなら気にしない、でも大丈夫そうですが、パターンマッチの `case` を使った数だけ出るようなので、割と辛いのでは、と思ったのですが、パース時のみで実行中は出ないので、気にならないかもしれません。

## [r67579](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67572_67600#r67579)

- [ ] *hatenablog* compct → compact ?

## [r67583](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67572_67600#r67583)

- [ ] *hatenablog* `T_ICASS` → `T_ICLASS` ?

# 2019-04-16

- net/imap の SNI 対応はバックポートされているはずなので、こういう場合の NEWS はどうあるべきなのかが気になります。

# 2019-04-15

## [r67560](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67550_67563#r67560)

- [ ] *hatenablog* <https://github.com/ruby/csv/blob/master/NEWS.md#308---2019-04-11> が `-` の前までしかリンクになってない?

# rurema

- [ ] *rurema* `reline`
- [ ] *rurema* `GC.compact`
- [ ] *rurema* パターンマッチ: 文法, `#deconstruct`, `#deconstruct_keys`
