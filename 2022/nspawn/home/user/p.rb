inf = 1.0/0.0
nan = inf/inf
[0.0, 1.0, 3.0, inf, -inf, nan].each do |x|
  %w(f d e E g G).each do |f|
    v = [x].pack(f).unpack(f)
    if x.nan?
      p [x, f] unless v.first.nan?
    else
      p [x, f] unless [x]==v
    end
  end
end
__END__
debian@debian-ppc64el:~$ ruby p.rb
[1.0, "e"]
[1.0, "g"]
[3.0, "e"]
[3.0, "g"]
