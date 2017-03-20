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

  assert_true (finish - start) > (timer_msec / 1000)
end

assert("Timer#run_with_signal") do
  timer_msec = 5000
  finish = nil

  SignalThread.trap(:USR2) do
    finish = Time.now
  end

  th = TimerThread.new
  start = Time.now
  th.run_with_signal timer_msec, :USR2

  while th.running? do
    sleep 1
  end
  assert_true (finish - start) > (timer_msec / 1000)
end
