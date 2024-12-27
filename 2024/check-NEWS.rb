#!/usr/bin/env ruby

status = true

news = File.read('../NEWS.md')

len = "[Feature #14413]:".size
news.scan(/\[(\[\w+ \#(\d+)\])\]/) do |link, num|
  next if /^#{Regexp.quote(link)}.*/ =~ news
  printf "\e[31m%-#{len}s https://bugs.ruby-lang.org/issues/%d\e[0m\n", "#{link}:", num
  status = false
end

news.scan(/^(\[[^\[\]]+\]):/) do |link,|
  next if news.include?("[#{link}]")
  next if news.match?(/\s#{Regexp.quote(link)}[\s.]/)
  next if news.match?(/\[[^\[\]]+\]#{Regexp.quote(link)}/)
  printf "\e[31mUnused footnote %s\e[0m\n", link
  status = false
end

# ruby -e 'while gets("\n\n"); s=$_; end; puts s' ../NEWS.md | sort -t/ -k5 -n
prev_num = 0
news.scan(/^(\[\w+ \#(\d+)\]): .*\/(\d+)$/) do |link, num, num2|
  if num != num2
    printf "\e[31mnumber mismatch %s\e[0m\n", $&
  end
  num = num.to_i
  if num <= prev_num
    printf "\e[31m%s %d <= %d\e[0m\n", link, num, prev_num
    status = false
  end
  prev_num = num
end

vers = news.scan(/^ *\* (\S+) (\d+\.[\w.]+)$/).to_h
gem_list_vers = `gem list`.scan(/^(\S+) \((?:default: )?(\d+\.[\w.]+)\)$/).to_h

gem_list_vers['RubyGems'] = `gem -v`.chomp

map_name = {
}

vers.map do |name, ver|
  orig = name
  if /\A\[(.+)\]\[\1\]\z/ =~ name
    name = $1
  end
  if gem_list_vers.key?(name)
    { name: name,  news_ver: ver, gem_ver: gem_list_vers[name], match: (ver == gem_list_vers[name]) }
  elsif gem_list_vers.key?(name = name.downcase)
    { orig: orig, name: name,  news_ver: ver, gem_ver: gem_list_vers[name], match: (ver == gem_list_vers[name]) }
  elsif gem_list_vers.key?(name = name.sub('::', '-'))
    { orig: orig, name: name,  news_ver: ver, gem_ver: gem_list_vers[name], match: (ver == gem_list_vers[name]) }
  elsif gem_list_vers.key?(name = map_name[orig])
    { orig: orig, name: name,  news_ver: ver, gem_ver: gem_list_vers[name], match: (ver == gem_list_vers[name]) }
  else
    { name: orig }
  end
end.sort_by do |h|
  [
    if h.key?(:match)
      h[:match] ? 0 : 1
    else
      2
    end,
    h[:name],
  ]
end.each do |h|
  if h[:match]
    puts "\e[32m#{h.inspect}\e[0m" if false
  else
    puts "\e[31m#{h.inspect}\e[0m"
    status = false
  end
end

exit status
