- あとでまとめ直してブログに移動する予定なので、こっちにはあまりリンクしないで欲しいです。
- <https://ruby-trunk-changes.hatenablog.com> へのコメントは *hatenablog* をつけることにしました。
- [rurema](https://github.com/rurema/doctree) 用のメモには *rurema* をつけることにしました。

# 2019-04-30

## [a116f04cca](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190430#a116f04cca)

- [ ] *hatenablog* `.travis.yaml` → `.travis.yml` ?

## [040b37f8b4b8d0a4931ee9b7c15b57f9f918639a](https://github.com/ruby/ruby/commit/040b37f8b4b8d0a4931ee9b7c15b57f9f918639a)

- [ruby/snapshot](https://github.com/ruby/snapshot) で作成される snapshot/revision.h が 7 文字になっていたので 10 文字に変更
- ちょっと変更して毎回 tarball 作成して展開して snapshot/revision.h を確認していたのでかなり時間がかかりました。

## [7a34d8902ad93c0e487623cd99e6c23296a7a768](https://github.com/ruby/ruby/commit/7a34d8902ad93c0e487623cd99e6c23296a7a768)

- [ruby/snapshot](https://github.com/ruby/snapshot) の git pull の動作確認用のコミット

## [319eee0f4a](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190430#319eee0f4a)

- 英語版 Windows のデフォルトが IBM437 らしく、 AppVeyor 内の `Encoding.default_external` は `Encoding::IBM437` になっているらしい。

## [3be5907e734f9c88af577bb0b0e8ec2d66b7b2f7](https://github.com/ruby/ruby/commit/3be5907e734f9c88af577bb0b0e8ec2d66b7b2f7)

- ext/win32/lib/Win32API.rb の警告なしの代用品として lib/reline/windows.rb が使われるようになったら嫌だなあと思ったので、lib/reline/windows.rb の Win32API はトップレベルではなく Reline::Win32API とかにした方が良いのでは、と伝えると変えてもらえました。

## [c222f4d31fc5f0566fa969d8fbb948f8841daf94](https://github.com/ruby/ruby/commit/c222f4d31fc5f0566fa969d8fbb948f8841daf94)

- `git clone --depth=1` で clone したものから `tool/make-snapshot` で tarball を作成すると空の ChangeLog ができていたのですが、その時の調査で `from ||= branch_beginning(url)` が `""` になって、その下で `^..commit-hash` という range になって `fatal: bad revision` になっていたのに、そういうものかと思ってスルーしていたのですが、そもそもここのチェックで例外にすべきだと思い直したので、チェック部分を変更しました。

# 2019-04-29

## [ruby/snapshot](https://github.com/ruby/snapshot)

- Heroku のログを確認すると `Errno::ENOENT: No such file or directory - git` だったので、 Dockerfile で git がインストールされていなかったので、 svn がもう使われていないのを `git grep svn` で確認して subversion を git に変更
- `docker build -t ruby-snapshot .` と `docker run -it ruby-snapshot bundle exec rake snapshot` で手元でも動作確認 (production 環境かどうかで動作をわけることはしていないので、手元だと AWS へのアクセスのところでエラーになって止まるのが正常)
- Heroku の Web から manual deploy してみたら buildpack のビルドが走ってしまった。
- [Building Docker Images with heroku.yml Is Generally Available \| Heroku](https://blog.heroku.com/build-docker-images-heroku-yml) を参考にして build だけの heroku.yml を作成して deploy してみたが、変わらず。
- Heroku の Web の Overview で Dyno formation が空になっていて、元々の指定がわからなかったので hsbt さんの deploy に rollback して確認
- `web` `/bin/bash` になっていたので heroku.yml に追加して、もう一度 Heroku の Web から manual deploy
- Heroku Scheduler での実行待ち

## [ruby/snapshot](https://github.com/ruby/snapshot) 続き

- stable-snapshot が作成されていなかったので再調査
- `docker run -it -v /tmp/pkg:/root/pkg ruby-snapshot /bin/bash` で調査
- `ruby ruby_2_6/tool/make-snapshot -archname=stable-snapshot -srcdir=ruby_2_6 pkg stable` と `stable` を指定すると良さそうだった
- 処理を追いかけていて `ChangeLog` が作成されていて shallow clone だと空になってしまことが判明して、さらに継続調査
- `git clone --single-branch https://github.com/ruby/ruby` を検討したが `stable` の方と処理が分かれるのが嫌だと思って不採用
- `stable` を指定した時に `git for-each-ref --format='%(refname:short)' 'refs/heads/ruby_[0-9]*'` 相当の処理でローカルブランチしか見えないようで、 `git checkout ruby_2_6` するなどしておく必要があった
- shallow clone をやめたので、毎回全部取ってくるのは重そうということで、 docker image に clone を入れておくことにした。
- ruby のサイズなら slug の size limit に余裕で収まるかと思っていたが、 [500MB 制限](https://devcenter.heroku.com/articles/slug-compiler#slug-size) に対して `du -shc ruby` が 282M なので、将来的に溢れる可能性もありそうだった。

- 調査用に作業イメージを残していたが、最後には不要なので `docker system prune` で掃除をしておく。

## [7875c42f64](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190429#7875c42f64)

- [ ] *hatenablog* `tool/vcs.r` → `tool/vcs.rb` ?

## [0d227d1ce6](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190429#0d227d1ce6)

- [ ] *hatenablog* `Etc.getloging` → `Etc.getlogin` ?

## [6bedbf4625](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190429#6bedbf4625), [50cbb21ba5](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190429#50cbb21ba5)

- [ ] *rurema* `Integer#[](range)`

# 2019-04-27

## <https://github.com/ruby/ruby/commit/8990779d3693b106fbca014518726ba53224f731>

- <https://github.com/ruby/ruby/commit/52cfb17086998b9434c9c786bfcf827197216c9a> で戻ってしまった変更を再適用
- <https://github.com/ruby/ruby/commit/c20aae965e2e79fcf4c443b266f7012157d5b23b> は他の変更もあるので、 `git cherry-pick c20aae965e2e79fcf4c443b266f7012157d5b23b` でどうなるかと思ったら、うまく `lib/irb/cmd/fork.rb` だけ再適用されたので、そのまま push

## <https://github.com/ruby/ruby/commit/c8b675adb902a67bf62a1a9945bade7c8becc4e8>

- <https://github.com/ruby/ruby/commit/52cfb17086998b9434c9c786bfcf827197216c9a> で戻ってしまった変更を再適用
- <https://github.com/ruby/ruby/commit/9a83922b666d4e26b84840757b16b0f9df6acef9> は気になった変更だけだったので `git cherry-pick 9a83922b666d4e26b84840757b16b0f9df6acef9` で問題なし

## [569c1ef6f1](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190427#569c1ef6f1)

- [ ] *hatenablog* <!-- irb の upstream からの再度同期。 タイミングで r67678 のぶんは巻き戻ってしまったようです。 --> 直前のコミット (Author: naruse, Committer: k0kubun) と重複しない差分にみえるのですが、 r67678 って巻き戻ってます?

## [48313f129a](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190427#48313f129a)

- コミットログに確認の実行ログだけ書いて説明を書き忘れたのですが、 2.6 でも `nil` が返ってくることがある、と、このメモを書いていて気づいたのですが、コミットログに書いた確認方法だと `Enumerator::ArithmeticSequence#begin` ではなく `Range#begin` になっていました。

ということで 2.6 でも `first` は `nil` が返ってくることがありますが、 `begin` は beginless range が入った 2.7 からのようです。

コミットログに書いた確認方法:
```
% ruby -ve 'p (nil..).first'
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin18]
nil
% ruby -ve 'p (nil..).begin'
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin18]
nil
```

正しい確認方法:
```
% ruby -ve 'p (nil..2).step(2).begin'
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin18]
Traceback (most recent call last):
-e:1:in `<main>': bad value for range (ArgumentError)
% ruby -ve 'p (nil..2).step(2).first'
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin18]
Traceback (most recent call last):
-e:1:in `<main>': bad value for range (ArgumentError)
zsh: exit 1     ruby -ve 'p (nil..2).step(2).first'
% ruby -ve 'p (1..-1).step(2).first'
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin18]
nil
```
```
% ruby -ve 'p (nil..2).step(2).begin'
ruby 2.7.0dev (2019-04-27 trunk 3067370f61) [x86_64-darwin18]
nil
% ruby -ve 'p (nil..2).step(2).first'
ruby 2.7.0dev (2019-04-27 trunk 3067370f61) [x86_64-darwin18]
nil
% ruby -ve 'p (1..-1).step(2).first'
ruby 2.7.0dev (2019-04-27 trunk 3067370f61) [x86_64-darwin18]
nil
```

- [x] *rurema* <https://github.com/rurema/doctree/pull/1852>

# 2019-04-26

## [b55201dd09](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190426#b55201dd09)

- [ ] *hatenablog* f6cd383f9dc3ae1204a5fba8f56ee7826cbce って何だろう? 直前のコミットは 94af6cd383f9dc3ae1204a5fba8f56ee7826cbce だし、 `git show f6cd383f9dc3ae1204a5fba8f56ee7826cbce` しても出てこないし。

## [Do not color IRB output on 'dumb' TERM](https://github.com/ruby/ruby/commit/022cbb278f381e5774a5d0277a83127c6f6b4802)

- `TERM=dumb` と `TERM=emacs` を特別扱いするのをみたことがあるけど、どういう時にそう設定されることがあるのかは、ちゃんと調べたことがないなあ。

## [1cef6a0c0c](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunnk_changes_20190426#1cef6a0c0c)

- <https://github.com/ruby/ruby/commit/1cef6a0c0c996ab87ef41dfeede3203ee3c811dc>
- `make -j` で `.ext/**/*.rb` よりも timestamp の mtime が未来の時に cp で Permission denied になるようなので、その確認用の stat 追加です。
- `stat` コマンドは Linux だと秒未満も表示されたのですが、 macOS だと表示されなかったのと `-t` で指定できる `strftime(3)` 形式の timefmt でも `%N` に未対応で難しそうだったので、前後関係が比較できればいいので、 `File::Stat#mtime` から `to_f` したものを表示するようにしました。

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

# 2019-04-14

## [r67533](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67530_67549#r67533)

- [ ] *hatenablog* `mjit*.{hc}` はシェル風に書くと、ブレース展開なら `mjit*.{h,c}` でグロブなら `mjit*.[hc]` になりそう。

# 2019-04-11

## [r67517](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67513_67518#r67517)

- [ ] *rurema* [DOC] Add `ifnone` example to `find` documentation [ci skip]
  <https://github.com/ruby/ruby/pull/2110>

# 2019-04-10

## [r67479](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67477_67501#r67479)

- [ ] *rurema* `GC.compact`
- [Feature #15626](https://bugs.ruby-lang.org/issues/15626)

# 2019-04-06

## [r67455](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67447_67458#r67455)

- [ ] *hatenablog* `tool/downloaderrb` → `tool/downloader.rb` ?

# 2019-04-02

## [r67405](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67401_67414#r67405)

- [ ] *hatenablog* `unpoisone_xxx` → `unpoison_xxx` ?

## [r67411](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67401_67414#r67411)

- [ ] *hatenablog* `JAPANESE_ERA_INITIALS を JISX0301_ERA_INITIALS を` → `~ を ~ に` ?

# rurema

- [ ] *rurema* `reline`
- [ ] *rurema* パターンマッチ: 文法, `#deconstruct`, `#deconstruct_keys`
- [ ] *rurema* 令和対応はサンプルコードに反映する? <https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_67471_67476>
- [ ] *rurema* beginless range 対応
- [ ] `Logger#level=` が Socket のように Symbol でも指定できるようになると短くかけるようになって嬉しいのかも。
