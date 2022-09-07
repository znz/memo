# History of Japanese Ruby reference manual, and future

author
:   Kazuhiro NISHIYAMA

institution
:   株式会社Ruby開発

content-source
:   RubyKaigi 2022

date
:   2022-09-10

allotted-time
:   30m

theme
:   lightning-simple

# self.intro

- Kazuhiro NISHIYAMA
- One of Ruby committers
- One of owners of <https://github.com/rurema>
- Ruby Development Inc.
  - one of Silver Sponsors
- Twitter, GitHub: `@znz`

## note

まずは自己紹介からです。
Ruby のコミッターの一人です。
そして今回の話に出てくるるりまOrganizationのowner権限を持っている一人です。

現在の所属は株式会社Ruby開発で、今回のRubyKaigi 2022のシルバースポンサーのうちの1社です。

Twitter や GitHub ではゼットエヌゼットというアカウントで活動しています。

# Agenda

- What is rurema?
- History
- Future

## note

まずるりまとは何かという話をした後、歴史の話をして、今後どうしていきたいかという話をします。

# What is rurema (るりま)?

- Japanese Ruby reference manual
  Rubyリファレンスマニュアル刷新計画
- <https://github.com/rurema>
  - [rurema/doctree](https://github.com/rurema/doctree)
    - documents
  - [rurema/bitclust](https://github.com/rurema/bitclust)
    - original system

## note

まず、「るりま」とは何かというと、Rubyリファレンスマニュアル刷新計画のことで、主に2つのリポジトリがあります。
ひとつはドキュメントのドックツリーで、もうひとつは独自システムのビットクラストです。

# るりま != るびま

- Rubyist Magazine
  - <https://magazine.rubyist.net/>
  - <https://github.com/rubima>
- a similar name, but not related
- in FAQ (rubima exist since that time)

  > Q. るびま、って「ネギま！」のぱくりですか？
  > A. 違います。多分。「るびま」を考えた人たちは「ネギま！」を知りませんでした (または、言われるまで気付かなかった)。

## note

ちょっと話がそれますが、似たプロジェクトに「るびま」があって、こちらはルビーストマガジンの略で、
名前は似ていますが、直接の関係はありません。

FAQ に

> Q. るびま、って「ネギま！」のぱくりですか？
> A. 違います。多分。「るびま」を考えた人たちは「ネギま！」を知りませんでした (または、言われるまで気付かなかった)。

と書いてあって、ネギまという漫画がはやっていた頃から存在しています。

# History of Japanese Ruby reference manual (1/2)

- Before Ruby 1.4.6
  - <https://ftp.ruby-lang.org/pub/ruby/doc/>
  - Documents written in *RD*
  - English:  [ruby-man-1.4.6.tar.gz](https://ftp.ruby-lang.org/pub/ruby/doc/ruby-man-1.4.6.tar.gz)
  - Japanese: [ruby-man-1.4.6-jp.tar.gz](https://ftp.ruby-lang.org/pub/ruby/doc/ruby-man-1.4.6-jp.tar.gz)
- Ruby 1.6 to 1.8 era
  - Edit documents on *RWiki*
  - RWiki is a Wiki using RD + some extensions

## note

現在入手しやすい最古のドキュメントとして、1.4.6時代にRDで書かれたものがこのURLからダウンロードできます。
このうち、日本語の方を元にして、RWikiというRD記法をベースにして、いくつか拡張された記法を使った Wiki で、しばらくの間、ドキュメントを更新していました。

# History of Japanese Ruby reference manual (2/2)

- In Ruby 1.8 era
  - Started *rurema* (Rubyリファレンスマニュアル刷新計画)
  - *bitclust* supports *RD* based original syntax
    - bitclust does not use *RDtool* (<https://rubygems.org/gems/rdtool>)
  - Import documents from *RWiki*

## note

1.8時代にRubyリファレンスマニュアル刷新計画が始まり、
RDベースの独自記法のbitclustというシステムに移行しました。

bitclustはRDの処理に既存のRDtoolは使わずに独自の拡張を含む処理系になっています。

# License of documents

- License exists in the edit form of RWiki with
  - license can be changed if there is an agreement on ML (rubyist ML on freeml. it already removed, and freeml service ended)
- License changed to *Creative Commons — Attribution 3.0 Unported*
  <https://github.com/rurema/doctree/blob/master/refm/doc/license.rd>

## note

るりまプロジェクトの開始のときに、同時にドキュメントのライセンスについても
使いやすいものにしようという話がありました。

あらかじめ RWiki での編集に移行するときに、将来をみすえて、ライセンスの変更手順についても書いておいたので、
当時使っていた freeml の rubyist ML で合意を取ってライセンスを変更できました。

# System improvements in bitclust era

- Convert documents from EUC-JP to UTF-8
- Support code colorize (`#@samplecode`)
  - `#@` is prefix of pre-processors
- Output as chm, ePub too
  - may not work now
    - if it does not work, contribution chance!
  - default: static html (used on docs.ruby-lang.org)

## note

bitclust時代にシステムが関わる改善点がいくつかあったので、主なものをいくつか紹介します。

まず、ドキュメントがEUC-JPで書かれていたのを時代の変化に合わせてUTF-8に移行しました。
そして、サンプルコードが色つけに対応しました。

それから、今も使えるかどうかは試していないのでわからないのですが、chmやePubの出力にも対応しています。
試してみて動かないようだったら、OSS に貢献するチャンスです。

現在のデフォルトの出力は静的なHTMLで、公式のドキュメントサイトの docs.ruby-lang.org でも使われています。

# Project current status

- Documentation improvement sub-projects
- Support new versions of Ruby
- <https://rurema-review.connpass.com/>

# Documentation improvement sub-projects

- Add executable sample codes
  - <https://github.com/rurema/doctree/issues/433>
    コピペ可能なサンプルコードを整備する
- Colorize sample codes

→ stalled

## note

ドキュメントを改善するためのサブプロジェクトとして、「コピペ可能なサンプルコードを整備する」やサンプルコードの色つけ対応がありますが、
手を動かしてくれる人たちが忙しくなってしまったからか、ほとんど終わったからなのか、現状はほぼ止まっているようです。

# Support new versions of Ruby

- Well supported
  - Method changes (new, changed arguments or functionality, removed)
- Insufficient supported
  - Syntax changes (pattern match, `&.`, ...)
  - Changes are not clear where to write

## note

新しいRubyのバージョン対応の現状は、
メソッドの変更はかなり対応できていて、
文法など、どこに書くのかはっきりしないものは対応が不十分です。

# rurema-review

- https://rurema-review.connpass.com/
  - every Tuesday night
  - るりまレビュー会 → るりまもくもく会
  - after 鹿児島Ruby会議01
- Many pull requests merged

→ inactive

## note

鹿児島Ruby会議01の懇親会でるりまのpull requestがたまっているなどの状況をどうにかしたいと数人で話して、
毎週定期的にオンラインで何かする時間を開催していました。

結果的にたくさんの pull requests をマージできました。

しかし、だんだん参加者が減ってしまって、現在は Slack での通知が続いているだけで、あまり活動できていません。

# Future plans

- Short term plans
- Middle term plans
- Long term plans

## note

最後に、現在の短期目標、中期目標、長期目標の話をします。

# RD based → Markdown based

- *Most important biggest short term plan*
  - Markdown is more familiar for many users
  - It makes more contributions
- I am investigating how to convert from current syntax

## note

最も重要で大きな短期目標は、RDベースの記法からマークダウンベースの記法への変更です。

ほとんどのユーザーにとって、markdown は RD よりも馴染みがあるので、貢献してくれる人が増えることが期待できます。

そのために、現在の記法からどう変換するのが良いかを調査中です。


# Convert pre-processors

- Version branching, include, ...
- I care about
  - Editors support what extensions
  - Do not break Markdown processor which does not support extensions (e.g. GitHub.com)

## note

RDベースの記法から変換するときに、bitclust独自のプリプロセッサのバージョン分岐やインクルードなどをどうするのが良いかなどを考えています。

たとえば、エディターがどういう拡張なら対応していて、編集しやすいかとか、どういう記法なら対応していない環境でも変なことにならないか、ということを気にしています。

# MethodList

- What is alternative of `MethodList`
- Current syntax is based on `def m(args)`
- Blocks have notation fluctuations
  - `{|x| ... }`, `{|x| block }`, or `&block`
- Return types are not used effectively

## note

RDに存在するメソッドリストがないので、その代わりに何を使うかも考える必要があります。

現状はできるだけメソッド定義の記法にあわせるというゆるい決まりがあるだけで厳密なチェックはされていません。
キーワード引数はこのゆるい決まりでうまく対応できていますが、特にブロックの書き方と返り値に表記揺れがあります。

返り値の型は表記にはあまり問題がおきていませんが、有効活用できていません。

# Other syntax

- `#@samplecode` → code block
- links and references → ? (thinking)

## note

他の記法の変換も考え中です。

サンプルコードはコードブロックに変換できますが、リンクや参照はどうするのか考え中です。

# Other short term plans and problems

- Clean up unused files, old files
- Not sure if tools are still usable
- **Lack of usage documentation**
  - This is most important for contributors
- Reproducible build
  - in container? devcontainer?

## note

その他の短期目標と問題点をざっと並べておくと、
もう使われていなかったり、古いファイルが残っているのを整理したいというのと、
toolsのファイルがまだ使えるのかどうかはっきりしない、
使い方のドキュメントが不足している、という点があります。

使い方のドキュメント不足は最重要課題と認識していて、貢献者を増やすのに一番重要だと思っています。

そして、再現可能なビルドも何らかの手段でもっと進めたいと思っています。

# Middle term plans

- Cooperation with RBS
- Cooperation with IRB
- Executable sample code using WASM
- Clean up unbundled libraries

## note

中期目標としては、周辺ツールとの連携を進めたいと思っています。
また、標準添付ではなくなったライブラリのドキュメントも古いまま放置するのではなく、新しいバージョンでは生成されないようにするなどの何らかの対処をしたいと思っています。

# Long term plans

- I18n support
  - Hard to merge rdoc, so rurema will continue separately
  - gettext based?
  - or something else based?
  - It should be based on English, so unlikely to come true

## note

長期目標としては、日本語と英語以外への対応できるシステムにしたいですが、
英語ベースじゃないと他の言語に翻訳いてもらいにくいというのと、
RDocとは記法だけに限らず、ドキュメントの書き方が違いすぎて統一しにくいので、
遠い将来の夢になりそうです。

# end

- Short term most important plans to increase contributions
  - RD based → Markdown based
  - Improve usage documentation
- Middle term plans
  - Improve for users
- Resolve many historical problems progressively
- Contribution welcome!

## note

最後にまとめると、貢献を増やすための短期目標として、
RD ベースだと貢献しにくいので、Markdownベースに移行したいです。
そして、使い方のドキュメントも重視したいです。

中期目標としてはユーザー向けの改善を進めていきたいです。

その他歴史的経緯で課題が山積みなのを徐々に対処していきたいです。

最後に、みなさまの貢献をお待ちしています、ということで発表を終わります。
