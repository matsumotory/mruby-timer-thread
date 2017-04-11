##
## Timer Test
##

assert("Timer module") do
  assert_equal Module, Timer.class
end

assert("Timer::MRubyThread#run") do
  timer_msec = 500
  start = Time.now.to_i * 1000 + Time.now.usec / 1000

  # 500msec timer
  th = Timer::MRubyThread.new
  th.run timer_msec

  300.times do
    break unless th.running?
    usleep 10 * 1000
  end

  finish = Time.now.to_i * 1000 + Time.now.usec / 1000

  assert_true (finish - start) > timer_msec
end

assert("Timer::MRubyThread#run_with_signal") do
  timer_msec = 500
  finish = nil

  sth = SignalThread.trap(:USR2) do
    finish = Time.now.to_i * 1000 + Time.now.usec / 1000
  end

  th = Timer::MRubyThread.new
  start = Time.now.to_i * 1000 + Time.now.usec / 1000

  th.run_with_signal timer_msec, :USR2, sth.thread_id

  300.times do
    break unless th.running?
    usleep 10 * 1000
  end
  assert_true (finish - start) > timer_msec
end
