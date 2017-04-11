assert("Timer::POSIX with RTSignal, interval timer and block") do
  timer_msec = 10
  timer_sem = 0
  v1 = 0
  v2 = 0

  t2 = SignalThread.trap(:RT5) { v2 += 1; timer_sem = 1 }
  t1 = SignalThread.trap(:RT5) { v1 += 1; timer_sem = 1 }
  timeout = 0

  begin
    Timer::POSIX.new(thread_id: t2.thread_id, signal: :RT5).run(timer_msec)
    while timer_sem == 0
      usleep 10 * 1000 rescue nil
      timeout += 1
      break if timeout >= 300
    end
    assert_equal 0, v1
    assert_equal 1, v2
    timer_sem = 0
    timeout = 0

    #t1.kill :RT5
    Timer::POSIX.new(thread_id: t1.thread_id, signal: :RT5).run(timer_msec)
    while timer_sem == 0
      usleep 1000 rescue nil
      timeout += 1
      break if timeout >= 300
    end
    p t1.exception
    p t2.exception

    assert_equal 1, v1
    assert_equal 1, v2
  rescue NotImplementedError => e
    # In an unsupported platform (MacOS)
    assert_equal "Unsupported platform", e.message
  end
end
