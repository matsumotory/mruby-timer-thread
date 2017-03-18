##
## Timer Test
##

assert("Timer#run") do
  timer_msec = 5000

  start = Time.now

  # 5sec timer
  th = TimerThread.new
  th.run timer_msec

  while th.running? do
    sleep 1
  end

  finish = Time.now

  assert_true (start - finish) < (timer_msec / 1000 + 2)
end

assert("Timer#run_with_signal") do
  timer_msec = 5000
  finish = 1

  SignalThread.trap(:USR1) do
    finish = Time.now
  end

  timer = TimerThread.new
  start = Time.now

  timer.run_with_signal timer_msec, :USR

  while timer.running? do
    sleep 1
  end
  assert_true (start - finish) < (timer_msec / 1000 + 2)
end
