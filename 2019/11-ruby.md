# 2019-11-30

- 鹿児島Ruby会議01に参加して発表もした。
- docs.r-l.o の deploy 権限をもらって更新されていなかった原因を調査して修正。
- コーヒーブレイクの時間をできるだけ使うようにしていたけど、修正を頑張っていた間は話を集中して聞けず。

- https://docs.ruby-lang.org/ja/latest/method/Kernel/m/abort.html の説明が古い。 exit や exit! も含めて rdoc からの翻訳に差し替えたい。

- 懇親会の時に duolingo の友達をフォローで追加できた。

# 2019-11-11

`exit 1` するシェルスクリプトを `git` としてパスに入れて `make check` したら `rubygems` も失敗したけど、 CI だと通ってたのは https://github.com/ruby/ruby/blob/9d3213ac856e1f5930bda555d4d65b173c6cdf83/lib/rubygems/test_case.rb#L504 でパスになければ `skip` になっていたからだった。

https://github.com/ruby/ruby/commit/9d3213ac856e1f5930bda555d4d65b173c6cdf83 では実行できるかどうかで判定してしまった。

# ruby-trunk-changes 2019-11-08

https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20191108#eaa011ffdb
> .travis.yml の BASERUBY に古い ruby を使うテストで BASERUBy のバージョンを 1.9.3 から 2.2 に変更しています。 tool/mk_builtin_loader.rb などが BASERUBY で実行されるので要求バージョンが上がったようです。

BASERUBy?

# 2019-11-07

## default gem 化

gemspec 経由で version.rb で読み込まれる定数があると `autoload` がきかなくなってハマることがありそう。

```
% ruby /tmp/a.rb
Net::SMTP
[]
% cat /tmp/a.rb
module Net
  class SMTP; end
end
module Net
  autoload :SMTP, 'net/smtp'
end
p Net::SMTP
p $LOADED_FEATURES.grep(/smtp/)
```

# 2019-11-05

## octokit gem を試した

```
require 'octokit'
require 'yaml'
client = Octokit::Client.new(access_token: YAML.load(File.read(File.expand_path('~/.config/hub'))).dig('github.com', 0, 'oauth_token'))

client.user
pr = client.pull_requests('rurema/doctree', state: 'open')
reviews = client.pull_request_reviews('rurema/doctree', pr[0].number)
reviews[-1][:state] == 'APPROVED'
reviews[-1][:submitted_at]

statuses=client.statuses('rurema/doctree', pr[0][:head][:sha])
statuses.map{|s|s[:target_url]}
statuses.map{|s|s[:state]}

suites=client.list_check_suites_for_ref('rurema/doctree', pr[0][:head][:sha])
suites[:check_suites].map{|x| [x[:status], x[:conclusion]]}

client.github_meta
puts client.say

status=client.combined_status('rurema/doctree', pr[0][:head][:sha])
status[:state] == 'success'
```
