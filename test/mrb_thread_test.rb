##
## Timer Test
##

assert("Timer module") do
  assert_equal Module, Timer.class
end

assert("Timer::MRubyThread#run") do
  timer_msec = 2000

  start = Time.now

  # 5sec timer
  th = Timer::MRubyThread.new
  th.run timer_msec

  while th.running? do
    sleep 1
  end

  finish = Time.now

  assert_true (finish - start) > (timer_msec / 1000)
end

assert("Timer::MRubyThread#run_with_signal") do
  timer_msec = 2000
  finish = nil

  SignalThread.trap(:USR2) do
    finish = Time.now
  end

  th = Timer::MRubyThread.new
  start = Time.now
  th.run_with_signal timer_msec, :USR2

  while th.running? do
    sleep 1
  end
  assert_true (finish - start) > (timer_msec / 1000)
end
