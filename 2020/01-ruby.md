# 2020-01-26

- <https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20200126#838fa941f1>
- 知りたいのは前後関係で、(OpenCSW は共有環境らしいので) 他のプロセスがつなぎにきて close してしまっている可能性があるので、単独だとありえないタイミングで close されていないかどうかを知りたい感じです。
- という説明を書いていて気づいたけど、 assert_raise を抜けるまで server.accept を繰り返して、2回以上回っているかどうかを assert すると良いのかもしれない。
