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
timer = TimerThread.new
timer.run timer_msec

while timer.running? do
  sleep 1
  puts "master thread sleeping loop"
end

puts "timer thread finish."
```

- blocking timer

```ruby
timer = TimerThread.new


timer.run 3000

puts "main thread sleeping..."

sleep 1

puts "waiting timer"

timer.blocking_handler do
  puts "finish timer"
end

puts "finish main thread"
```

## License
under the MIT License:
- see LICENSE file
