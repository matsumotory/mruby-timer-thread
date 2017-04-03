assert("Timer::POSIX with RTSignal, interval timer and block") do
  #def assert_equal(*a); p a; end
  timer_msec = 10
  sem = false
  v1 = 0
  v2 = 0

  t1 = SignalThread.trap(:RT5) { v1 += 1; sem = true }
  t2 = SignalThread.trap(:RT5) { v2 += 1; sem = true }

  begin
    Timer::POSIX.new(tid: t2.tid, signal: :RT5).run(timer_msec)
    until sem
      usleep 1000 rescue nil
    end
    assert_equal 0, v1
    assert_equal 1, v2
    sem = false

    Timer::POSIX.new(tid: t1.tid, signal: :RT5).run(timer_msec)
    until sem
      usleep 1000 rescue nil
    end
    assert_equal 1, v1
    assert_equal 1, v2
  rescue NotImplementedError => e
    # In an unsupported platform (MacOS)
    assert_equal "Unsupported platform", e.message
  end
end
