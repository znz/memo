# 2023-01

## commits

- <https://github.com/ruby/ruby/commit/2fa3fda0c4534c7ba3cf9ab9c1963afdeda45ac8>
- <https://github.com/ruby/ruby/commit/8ae4e3ddc9de89821a04e09f19d3bb1aefc4617d>

## issues

- <https://github.com/ruby/setup-ruby/issues/447>
- <https://github.com/ohler55/oj/issues/834>

## pr

- <https://github.com/ruby/benchmark/pull/17>
- <https://github.com/ruby/ruby-builder/pull/13>
- <https://github.com/ruby/jruby-dev-builder/pull/1>
- <https://github.com/ruby/fileutils/pull/106>

# 2023-02

## pr

- <https://github.com/yasslab/railsguides.jp/pull/1412>

# 2023-03

## commits

- <https://github.com/ruby/ruby/commit/5cffa69c1babb80be17d2544a430dce0f2c22b4e>

## issues

- <https://github.com/stefankroes/ancestry/issues/636>

# 2023-04

## commits

- <https://github.com/ruby/actions/commit/b105aad95d851d30746dc3f31616d73c738ac91f>
- <https://github.com/ruby/ruby/commit/2f6539fc9407e900d13416e20e521a413f900b15>
- <https://github.com/ruby/ruby/commit/8519d94d3d8511080d3724fd328926d443cb95fa> <https://bugs.ruby-lang.org/issues/19605>

## pr

- <https://github.com/ruby/www.ruby-lang.org/pull/3031>
- <https://github.com/ruby/www.ruby-lang.org/pull/3032>
- <https://github.com/yasslab/railsguides.jp/pull/1443>

# 2023-05

## pr

- <https://github.com/sameersbn/docker-redmine/pull/516>

# 2023-05

## commits

- <https://github.com/ruby/rurema-search/commit/21f7e8c65e651f596b02460b2ecf9b0248ddb0a3>
- <https://github.com/ruby/rurema-search/commit/7c9f45fcc3ad3a3dfb92c467bcdef90a922ccebc>
- <https://github.com/ruby/rurema-search/commit/93cc7d7a1dfb503731729ec06ed8e65d476b27a6>
- <https://github.com/ruby/rurema-search/commit/86353d0352e0df2d5d3613146d28823f9f11822b>

# 2023-06

## commits

- <https://github.com/ruby-jp/ruboty-ruby-jp>
  - Add monkey patch for ruboty-slack_rtm
  - Fix ruboty-golf

## issues

- <https://github.com/ruby/irb/issues/620>

# 2023-07

## pr

- <https://github.com/sameersbn/docker-redmine/pull/518>

## commits

- <https://github.com/ruby/actions/commit/554cd6de9b19e431dfb02473e3e5f327bc588dcb>
- <https://github.com/ruby/ruby/commit/ea2fc58d9ae4da9bf280ce2d4fd87896aa4b693d>

## issues

- <https://github.com/rubocop/rubocop-factory_bot/issues/58>
- <https://github.com/rails/spring/issues/697>

# 2023-08

## commits

- <https://github.com/ruby/ruby/commit/3f010d48fc0be34799eeeb5661e7ffb3b5319d5c>
- <https://github.com/ruby/actions/commit/a29e6dd466666a341e00561ad4efbd3e364b552a>
- <https://github.com/ruby/actions/commit/ca19d5cd8115d0db6300be6d0f7b2e56332e0650>

# 2023-09

## pr

- <https://github.com/ruby/rubyci/pull/409>

## issues

- <https://bugs.ruby-lang.org/issues/19902>

# 2023-10

## pr

- <https://github.com/ruby/ruby/pull/8622>
- <https://github.com/rurema/doctree/pull/2836>

## commits

- <https://github.com/ruby/ruby/commit/fe08839d8ac3b830c3b88626043da30f57de73c9>
- <https://github.com/ruby/ruby/commit/c782c6fd4cedd63021afef03385da6ff15d27321>
- <https://github.com/ruby/ruby/commit/77d7ac7c066e281b9c41d04b7fc3315e41aa6485>
- <https://github.com/ruby/ruby/commit/8b3a2d56fd1041d0ec2dfdfb82f865592941fb05>
- <https://github.com/ruby-jp/ruboty-ruby-jp/commit/54595c25cc8d482e55b21c6ad3eac4e7e6f57618>

```console
% ruby -e 'gem "activesupport", "~> 7.0.0"; require "active_support"; p 1.present?'
true
% ruby -e 'gem "activesupport", "~> 7.1.0"; require "active_support"; p 1.present?'
-e:one:in `<main>': undefined method `present?' for 1:Integer (NoMethodError)

gem "activesupport", "~> 7.1.0"; require "active_support"; p 1.present?
                                                              ^^^^^^^^^
% ruby -e 'gem "activesupport", "~> 7.1.0"; require "active_support"; require "active_support/core_ext"; p 1.present?'
true
```

# 2023-11

## commits

- <https://github.com/ruby/actions/commit/59ae9041f956a9349af8885d226c77230963b3f6>
- <https://github.com/ruby/actions/commit/097bbfd7dcf46b950ee0c87193ac87c44f8d0472>
- <https://github.com/ruby/ruby/commit/f7d268898e72aab6988b7e4694d920648a6de90e>
- <https://github.com/ruby/ruby/commit/062b59ba9aa0f6d5057e0187a04d11b75d623952> <https://github.com/ruby/ruby/commit/60568e971e1e7061bfe365e1fbf8a70a598c241a>

# pr

- <https://github.com/elastic/elasticsearch-rails/pull/1065>
