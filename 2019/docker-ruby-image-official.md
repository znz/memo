# Docker のオフィシャル ruby イメージとは?

author
:   Kazuhiro NISHIYAMA

content-source
:   Docker Meetup Kansai #5 (19.11)

date
:   2019/11/22

allotted-time
:   5m

theme
:   lightning-simple

# 自己紹介

- Ruby コミッター

# OFFICIAL とは?

```
% docker search ruby | head -n 5
NAME                         DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
ruby                         Ruby is a dynamic, reflective, object-orient…   1753                [OK]
redmine                      Redmine is a flexible project management web…   797                 [OK]
jruby                        JRuby (http://www.jruby.org) is an implement…   88                  [OK]
circleci/ruby                Ruby is a dynamic, reflective, object-orient…   65
```

# OFFICIAL の image

- <https://github.com/docker-library/ruby>
- (たぶん) コミュニティによるメンテナンス
- Docker 社がやっている?
- alpine などにも対応

# rubylang の image

- <https://hub.docker.com/u/rubylang/>
- Ruby コミッターによるメンテナンス

# rubylang/ruby

- bundler 周りなどの余計な環境変数を設定していない
- 主に特定 OS バージョンのみ
  - 今だと Ubuntu bionic
  - alpine などに対応する余裕がない

# rubylang/all-ruby

- 全てのリリースバージョンの ruby を網羅したイメージ
- バージョン間の差などを調べるのに便利

# rubylang/all-ruby 使用例

```
% docker run -it --rm rubylang/all-ruby ./all-ruby -e 'print("hello")'
ruby-0.49             hello
...
ruby-2.7.0-preview1   hello
% docker run -it --rm rubylang/all-ruby env ALL_RUBY_SINCE=ruby-2.3 ./all-ruby -e 'p :world'
ruby-2.3.0          :world
...
ruby-2.7.0-preview1 :world
```

# rubylang/rubyfarm

- bisect 用に作られている開発版のほぼ全リビジョンの docker image

# まとめ

- OFFICIAL が品質が高いとは限らない
- ソフトウェアの upstream も docker のエキスパートとは限らない
- rubylang には色々なイメージがあります
- 他のソフトウェアのイメージの状況も知りたいです
