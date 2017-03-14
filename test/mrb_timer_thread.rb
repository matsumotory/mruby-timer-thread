##
## Timer Test
##

assert("Timer module") do
  assert_equal Module, Timer.class
end

assert("MRubyThread#run") do
  timer_msec = 5000

  start = Time.now

  # 5sec timer
  th = Timer::MRubyThread.new
  th.run timer_msec

  while th.running? do
    sleep 1
    puts "master thread sleeping loop"
  end

  finish = Time.now

  assert_true (start - finish) < (timer_msec / 1000 + 2)
end
