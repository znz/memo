# 2020-10 のメモ

## NEWS.md のチケット参照の更新

```
ruby -e 'news = File.read("../NEWS.md")
len = "[Feature #14413]:".size
news.scan(/\[(\[\w+ \#(\d+)\])\]/) do |link, num|
  next if /^#{Regexp.quote(link)}.*/ =~ news
  printf "%-#{len}s https://bugs.ruby-lang.org/issues/%d\n", "#{link}:", num
end'
```

で出力があれば適当に追加して、 Emacs 上で issues へのリンクを含む footnotes の行を選択して `M-| sort -t/ -k 5 -n` でチケット番号順にソート
