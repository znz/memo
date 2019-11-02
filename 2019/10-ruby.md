# ruby memo

## date 難しい

https://github.com/ruby/date/pull/12#issuecomment-546618590

    # 2.6
    irb(main):002:0> Date.today(Date::ITALY)
    => #<Date: 2019-10-27 ((2458784j,0s,0n),+0s,2299161j)>
    irb(main):003:0> Date.today(Date::ENGLAND)
    => #<Date: 2019-10-27 ((2458784j,0s,0n),+0s,2361222j)>
