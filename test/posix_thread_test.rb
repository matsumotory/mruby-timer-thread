assert("Timer::POSIX with RTSignal, interval timer and block") do
  timer_msec = 10
  q1 = Queue.new
  q2 = Queue.new

  t1 = SignalThread.trap(:RT5) { q1.push true }
  t2 = SignalThread.trap(:RT5) { q2.push true }

  begin
    Timer::POSIX.new(thread_id: t1.thread_id, signal: :RT5).run(timer_msec)
    assert_true q1.pop

    Timer::POSIX.new(thread_id: t2.thread_id, signal: :RT5).run(timer_msec)
    assert_true q2.pop
  rescue NotImplementedError => e
    # In an unsupported platform (MacOS)
    assert_equal "Unsupported platform", e.message
  end
end
