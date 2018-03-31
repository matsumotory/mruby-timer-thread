##
## Timer Test
##

assert("Timer module") do
  assert_equal Module, Timer.class
end

assert("Timer::MRubyThread#run") do
  timer_msec = 500
  start = Time.now.to_i * 1000 + Time.now.usec / 1000

  # 5sec timer
  th = Timer::MRubyThread.new
  th.run timer_msec

  while th.running? do
    usleep 1000
  end

  finish = Time.now.to_i * 1000 + Time.now.usec / 1000

  assert_true (finish - start) > timer_msec
end

assert("Timer::MRubyThread#run_with_signal") do
  timer_msec = 500
  finish = Queue.new

  sth = SignalThread.trap(:USR2) do
    finish.push Time.now.to_i * 1000 + Time.now.usec / 1000
  end

  th = Timer::MRubyThread.new
  start = Time.now.to_i * 1000 + Time.now.usec / 1000

  th.run_with_signal timer_msec, :USR2, sth.thread_id

  while th.running? do
    usleep 1000
  end
  sleep 1
  assert_true (finish.pop - start) > timer_msec
end
