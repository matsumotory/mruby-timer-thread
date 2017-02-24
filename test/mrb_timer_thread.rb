##
## Timer Test
##

assert("Timer#run") do
  timer_msec = 5000

  start = Time.now

  # 5sec timer
  th = TimerThread.new
  th.run timer_msec

  while th.run? do
    sleep 1
    puts "master thread sleeping loop"
  end

  finish = Time.now

  assert_true (start - finish) < (timer_msec / 1000 + 2)
end
