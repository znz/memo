# rabbit memo

`rabbit-slide new --id rubykansai86-ruby-svn-to-git --base-name ruby-svn-to-git --markup-language markdown --title "Ruby svn to git" --tags ruby --allotted-time 20m --presentation-date 2019/05/11 --name "Kazuhiro NISHIYAMA" --email "zn@mbf.nifty.com" --rubygems-user znz --slideshare-user znzjp --speaker-deck-user znz`

```
% rake -T
2019-05-11 14:00:53.089 ruby[23574:47133355] *** WARNING: Method userSpaceScaleFactor in class NSView is deprecated on 10.7 and later. It should not be used in new applications. Use convertRectToBacking: instead.
rake gem                   # gemを作成: pkg/rabbit-slide-znz-rubykansai86-ruby-svn-to-git-2019.05.11.gem
rake pdf                   # PDFを生成: pdf/rubykansai86-ruby-svn-to-git-ruby-svn-to-git.pdf
rake publish               # すべての公開可能な公開場所にこのスライドを公開
rake publish:rubygems      # Publish the slide to RubyGems.org
rake publish:slideshare    # Publish the slide to SlideShare
rake publish:speaker_deck  # Publish the slide to Speaker Deck
rake run                   # スライドを表示
rake tag                   # Tag 2019.05.11
real:1.48s  user:0.85s  sys:0.33s  cpu:79% mem:0+0k 2284pf+0w  IO:0+0  rake -T
% rake publish:rubygems
2019-05-11 14:00:58.499 ruby[23634:47133892] *** WARNING: Method userSpaceScaleFactor in class NSView is deprecated on 10.7 and later. It should not be used in new applications. Use convertRectToBacking: instead.
mkdir -p pkg
WARNING:  licenses is empty, but is recommended.  Use a license identifier from
http://spdx.org/licenses or 'Nonstandard' for a nonstandard license.
WARNING:  open-ended dependency on rabbit (>= 2.0.2) is not recommended
  if rabbit is semantically versioned, use:
    add_runtime_dependency 'rabbit', '~> 2.0', '>= 2.0.2'
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
  Successfully built RubyGem
  Name: rabbit-slide-znz-rubykansai86-ruby-svn-to-git
  Version: 2019.05.11
  File: rabbit-slide-znz-rubykansai86-ruby-svn-to-git-2019.05.11.gem
mv rabbit-slide-znz-rubykansai86-ruby-svn-to-git-2019.05.11.gem pkg/rabbit-slide-znz-rubykansai86-ruby-svn-to-git-2019.05.11.gem
/Users/kazu/.anyenv/envs/rbenv/versions/2.6.3/bin/ruby -S gem push pkg/rabbit-slide-znz-rubykansai86-ruby-svn-to-git-2019.05.11.gem --key znz
608777
Pushing gem to https://rubygems.org...
You have enabled multi-factor authentication. Please enter OTP code.
Code:   591Successfully registered gem: rabbit-slide-znz-rubykansai86-ruby-svn-to-git (2019.05.11)
real:39.02s  user:1.51s  sys:0.45s  cpu:5% mem:0+0k 66pf+0w  IO:0+0  rake publish:rubygems
% rake tag
2019-05-11 14:02:15.331 ruby[23712:47146664] *** WARNING: Method userSpaceScaleFactor in class NSView is deprecated on 10.7 and later. It should not be used in new applications. Use convertRectToBacking: instead.
git tag -a 2019.05.11 -m Publish 2019.05.11
git push --tags
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 177 bytes | 177.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To github.com:znz/rubykansai86-ruby-svn-to-git.git
 * [new tag]         2019.05.11 -> 2019.05.11
real:7.80s  user:0.82s  sys:0.29s  cpu:14% mem:0+0k 273pf+0w  IO:0+0  rake tag
```
