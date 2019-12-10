# 2019-12-10

## rurema レビュー会

- https://github.com/rurema のアイコン画像変更
- Slack 外でも募集しても良さそうだったので https://rurema-review.connpass.com/ を作って来週のイベントをたてた
- 3人でどんどんマージ
- マージ可能かどうか API で取れるかどうか調べてみたら https://developer.github.com/v3/git/#checking-mergeability-of-pull-requests に poll が必要と書いてあって不便そうだった
- https://github.com/rurema/doctree/pull/1502 をマージした時に変になったのか、 CI がこけていて `Range` の `#@end` の対応がずれていたことがわかったので https://github.com/rurema/doctree/pull/2049 で修正

# 2019-12-07

- Ruby関西 勉強会 で directpoll を使ってアンケートと鹿児島Ruby会議01での話の再演をした。
- zeitwerk 良さそうだった

# 2019-12-05

- `test_default_gems.rb` だけ動かしても再現しないので `make test-all TESTS="-v did_you_mean ruby/test_default_gems.rb"` でチェックしていた。

## TEST_RATIO

ripper のテストを参考にして RATIO をつけて require だけで Thread が動いていないかチェックするようにした。

```
% git grep -n TEST_RATIO ..
../test/ripper/assert_parse_files.rb:13:      TEST_RATIO = ENV["TEST_RIPPER_RATIO"]&.tap {|s|break s.to_f} || 0.05 # testing all files needs too long time...
../test/ripper/assert_parse_files.rb:20:      if (1...scripts.size).include?(num = scripts.size * TEST_RATIO)
../test/ruby/test_require_lib.rb:5:  TEST_RATIO = ENV["TEST_REQUIRE_THREAD_RATIO"]&.tap {|s|break s.to_f} || 0.05 # testing all files needs too long time...
../test/ruby/test_require_lib.rb:14:    next if TEST_RATIO < rand(0.0..1.0)
```

# 2019-12-04

- https://github.com/ruby/dbm/pull/5#issuecomment-561696809
- https://github.com/oneclick/rubyinstaller2/wiki/For-gem-developers
- `s.metadata["msys2_mingw_dependencies"] = "gdbm"` のように書いておくと gem のインストール時に依存パッケージを自動インストールできるらしい

# 2019-12-03

## rurema レビュー会

- 背景: rurema のレビューをオンラインで集まってできると良いなとしばらく前から思っていて、11月まではずっと空いている曜日はなさそうで難しかったので、何もできていなませんでした。
- [鹿児島Ruby会議01](https://k-ruby.github.io/kagoshima-rubykaigi01/)の懇親会で pocke さんと話をしていて、12月は火曜ならずっと空いてそうだったので、そこでやってみようということに。
- 時間は 20:00-21:00 に。
- というわけで ruby-jp#rurema でレビュー会を実施
- 接続方法は zoom で。初ホストだったので、よくわからないこともありました。
- よくわからずに「待機室」というのを有効にしてみたら、入るときにまず待機室に入ってホストがいちいち許可しないと参加できないという挙動だったので、設定を外しました。
- 無料で3人以上だと40分で終了なのですが、「Zoomからのギフト」というのが出てきて制限が解除されたので、1時間ぐらいやっていました。
- bitclust の issues からみていって pull request もみて、 doctree の方はサンプルコードが多いのでどうしようという話になって、とりあえず新しい pull request をみていって終わりました。
- `/remind #rurema zoomのURL at 20:00 every Tuesday` を設定
- 興味がある人は [ruby-jp Slack](https://ruby-jp.github.io/) に入って #rurema チャンネルに参加してください。
