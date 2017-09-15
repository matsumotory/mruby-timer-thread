assert("Timer::POSIX with RTSignal using direct specification of thread_id") do
  timer_msec = 10
  sem1 = false
  sem2 = false
  v1 = 0
  v2 = 0

  t1 = SignalThread.trap(:RT5) { v1 += 1; sem1 = true }
  t2 = SignalThread.trap(:RT5) { v2 += 1; sem2 = true }

  begin
    Timer::POSIX.new(thread_id: t2.thread_id, signal: :RT5).run(timer_msec)
    500.times do
      until sem2
        usleep 1000 rescue nil
        next
      end
      break
    end
    assert_equal 0, v1, "not increment 1st thread"
    assert_equal 1, v2, "increment 2nd thread"

    Timer::POSIX.new(thread_id: t1.thread_id, signal: :RT5).run(timer_msec)
    500.times do
      until sem1
        usleep 1000 rescue nil
        next
      end
      break
    end
    assert_equal 1, v1, "increment 1st thread"
    assert_equal 1, v2, "not increment 2nd thread"
  rescue NotImplementedError => e
    # In an unsupported platform (MacOS)
    assert_equal "Unsupported platform", e.message
  end
end
