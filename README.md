# mruby-timer-thread   [![Build Status](https://travis-ci.org/matsumotory/mruby-timer-thread.svg?branch=master)](https://travis-ci.org/matsumotory/mruby-timer-thread)

Simple Timer Thread class

## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'matsumotory/mruby-timer-thread'
end
```
## example

- non blocking timer

```ruby
timer_msec = 5000

# 5sec timer
timer = Timer::MRubyThread.new
timer.run timer_msec

while timer.running? do
  sleep 1
  puts "master thread sleeping loop"
end

puts "timer thread finish."
```

- blocking timer

```ruby
timer = Timer::MRubyThread.new


timer.run 3000

puts "main thread sleeping..."

sleep 1

puts "waiting timer"

timer.blocking_handler do
  puts "finish timer"
end

puts "finish main thread"
```

- POSIX timer
  - NOTE: POSIX timer not available on MacOS

```ruby
# Specify signal name if you want (default ot SIGALRM as timer_create's default)
# signal: nil will send no signal.
# you can add handlers with mruby-signal or mruby-signal-thread
timer = Timer::POSIX.new(signal: nil)
timer.run 5000

# You can create multiple timers (and are thread-safe by kernel)
sleep 1
timer2 = Timer::POSIX.new(signal: nil)
timer2.run 5000

while timer.running? or timer2.running? do
  sleep 1
  puts "Timer1 running: #{timer.running?} and Timer2 running: #{timer2.running?}"
end
# ...
```

- POSIX timer with interval

```ruby
# recommended mruby-signal-thread
SignalThread.trap :USR2 do
  puts "Current datetime: #{`date`.chomp}"
end

timer = Timer::POSIX.new(signal: :USR2)

# Invoke first timer after 5,000 msec,
# then start interval timer every after 3,000 msec
# like uv_timet_t or timer_create API
timer.run 5000, 3000

Current datetime: Mon Mar 27 07:25:31 UTC 2017
Current datetime: Mon Mar 27 07:25:34 UTC 2017
Current datetime: Mon Mar 27 07:25:37 UTC 2017
Current datetime: Mon Mar 27 07:25:40 UTC 2017
Current datetime: Mon Mar 27 07:25:43 UTC 2017
...
```

## License
under the MIT License:
- see LICENSE file
