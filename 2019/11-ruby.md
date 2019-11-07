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
