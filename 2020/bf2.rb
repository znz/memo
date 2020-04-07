#!/usr/bin/ruby
# frozen_string_literal: true

# https://ja.wikipedia.org/wiki/Brainfuck

HelloWorld = <<-SRC
 +++++++++[>++++++++>+++++++++++>+++++<<<-]>.>++.+++++++..+++.>-.
 ------------.<++++++++.--------.+++.------.--------.>+.
SRC

# http://vipprog.net/wiki/%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E8%A8%80%E8%AA%9E/Brainfuck.html
FizzBuzz = <<-SRC
++++++[->++++> >+>+>-<<<<<]>[<++++> >+++>++++> >+++>+
++++>+++++> > > > > >++> >++<<<<<<<<<<<<<<-]<++++>+++
>-->+++>-> >--->++> > >+++++[->++>++<<]<<<<<<<<<<[->-
[> > > > > > >]>[<+++>.>.> > > >..> > >+<]<<<<<-[> > > >]>[<+
++++>.>.>..> > >+<]> > > >+<-[<<<]<[[-<<+> >]> > >+>+<<<<<
<[-> >+>+>-<<<<]<]>>[[-]<]>[> > >[>.<<.<<<]<[.<<<<]>]>.<<<<
<<<<<<<]
SRC

# http://hakugetu.so.land.to/program/brainfuck/1-4.php
prime_number = <<-SRC
>++++[<++++++++>-]>++++++++[<++++++>-]<++.<.> +.<.> ++.<.> ++.<.> ------..<.>
.++.<.> --.++++++.<.> ------.>+++[<+++>-]<-.<.> -------.+.<.> -.+++++++.<.>
------.--.<.> ++.++++.<.> ---.---.<.> +++.-.<.> +.+++.<.> --.--.<.> ++.++++.<.>
---.-----.<.> +++++.+.<.> .------.<.> ++++++.----.<.> ++++.++.<.> -.-----.<.> +++++.+.<.> .--.
SRC

src = prime_number

jump_table = {}
stack = []
src.size.times do |n|
  case src[n]
  when '['
    stack.push n
  when ']'
    left = stack.pop
    jump_table[n] = left
    jump_table[left] = n
  end
end

tape = Hash.new(0)
ptr = 0
cursor = 0
tape[0] = 0
show = -> {
  print "\e7\e[1;1H"
  print "#{src[0...cursor]}\e[7m#{src[cursor]}\e[0m#{src[cursor+1..-1]}"
  puts
  (tape.keys.max+1).times do |i|
    c = tape[i] % 256
    if (0x20..0x7e).include?(c)
      str = sprintf('%02X=%c', c, c)
      space = ' '
    else
      str = '%02X' % c
      space = '   '
    end
    if ptr == i
      print "\e[7m#{str}\e[0m#{space}"
    else
      print "#{str}#{space}"
    end
  end
  print "\e8"
  sleep 0.01
}
puts "\e[2J\e[1;1H#{src}\n\n\n"
while cursor < src.size
  show.()
  case src[cursor]
  when '>'; ptr += 1
  when '<'; ptr -= 1
  when '+'; tape[ptr] += 1
  when '-'; tape[ptr] -= 1
  when '.'; putc tape[ptr]
  when ','; tape[ptr] = STDIN.getc.ord
  when '['
    if tape[ptr].zero?
      cursor = jump_table[cursor]
    end
  when ']';
    if tape[ptr].nonzero?
      cursor = jump_table[cursor]
    end
  end
  cursor += 1
end
puts
