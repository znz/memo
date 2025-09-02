require 'pp'
run do |env|
  PP.pp env.select{it[0].start_with?(/\A[A-Z]/)}, STDERR
  [200, {}, ["Hello World"]]
end
