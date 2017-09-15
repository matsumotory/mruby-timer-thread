assert("Timer::POSIX.new") do
  t = Timer::POSIX.new
  assert_equal Timer::POSIX, t.class
end

assert("Timer::POSIX#signo, #clock_id") do
  t = Timer::POSIX.new()
  # SIGALRM = 14
  assert_equal 14, t.signo
  assert_equal Timer::CLOCK_REALTIME, t.clock_id

  t = Timer::POSIX.new(signal: :INT)
  # SIGINT = 2
  assert_equal 2, t.signo
  assert_equal Timer::CLOCK_REALTIME, t.clock_id

  t = Timer::POSIX.new(signal: :RT3, clock_id: Timer::CLOCK_MONOTONIC)
  # SIGRTMIN+3
  assert_equal RTSignal.get(3), t.signo
  assert_equal Timer::CLOCK_MONOTONIC, t.clock_id

  t = Timer::POSIX.new(clock_id: Timer::CLOCK_MONOTONIC)
  # SIGALRM = 14 default if option clock_id exists
  assert_equal 14, t.signo
  assert_equal Timer::CLOCK_MONOTONIC, t.clock_id

  t = Timer::POSIX.new(signal: nil)
  # No send signal
  assert_nil t.signo
  assert_equal Timer::CLOCK_REALTIME, t.clock_id
end

assert("Timer::POSIX#interval?") do
  t = Timer::POSIX.new(signal: nil)
  t.run 3000
  assert_true !t.interval?
  t.stop

  t = Timer::POSIX.new(signal: nil)
  t.run 3000, 3000
  assert_true t.interval?
  t.stop
end

assert("Timer::POSIX#run") do
  timer_msec = 200

  pt = Timer::POSIX.new(signal: nil)
  begin
    start = Time.now.to_i * 1000 + Time.now.usec / 1000
    pt.run timer_msec

    500.times do
      if pt.running?
        usleep 1000
        next
      end
      break
    end
    finish = Time.now.to_i * 1000 + Time.now.usec / 1000
    assert_true (finish - start) > timer_msec
  rescue NotImplementedError => e
    assert_true "Unsupported platform", e.message
  end
end

assert("Timer::POSIX#run in parallel") do
  timer_msec = 200
  gap_msec = 100

  pt1 = Timer::POSIX.new(signal: nil)
  pt2 = Timer::POSIX.new(signal: nil)
  begin
    start = Time.now.to_i * 1000 + Time.now.usec / 1000
    pt1.run timer_msec
    usleep gap_msec * 1000 # 100 msec
    pt2.run timer_msec

    assert_true !pt1.running? && pt2.running?, "Thread#1 should halt first"

    500.times do
      if pt2.running?
        usleep 1000
        next
      end
      break
    end
    finish = Time.now.to_i * 1000 + Time.now.usec / 1000
    assert_false pt2.running?, "Thread should be stopped"
    assert_true((finish - start) > (timer_msec + gap_msec), "Wait")
  rescue NotImplementedError => e
    assert_true "Unsupported platform", e.message
  end
end

assert("Timer::POSIX#run in many parallel") do
  timer_msec = 100
  gap_msec = 50
  pts = (1..10).map { Timer::POSIX.new(signal: nil) }

  begin
    start = Time.now.to_i * 1000 + Time.now.usec / 1000
    pts.each_with_index do |pt, i|
      pt.run timer_msec
      usleep gap_msec * 1000 unless i == 9
    end

    500.times do
      if pts.any? {|pt| pt.running? }
        usleep 1000
        next
      end
      break
    end

    finish = Time.now.to_i * 1000 + Time.now.usec / 1000
    assert_true (finish - start) > (timer_msec + gap_msec * 9)
  rescue NotImplementedError => e
    assert_true "Unsupported platform", e.message
  end
end

assert("Timer::POSIX with RTSignal, interval timer and block") do
  timer_msec = 200
  count = 0

  SignalThread.trap(:SIGRT2) { count += 1 }
  pt = Timer::POSIX.new(signal: :SIGRT2)

  begin
    start = Time.now.to_i * 1000 + Time.now.usec / 1000
    pt.run timer_msec, timer_msec

    # Wait until first timer kicked & interval timers invoked 3 times...
    # Block will be called total 4 times
    500.times do
      if count < 4
        usleep 1000
        next
      end
      break
    end
    finish = Time.now.to_i * 1000 + Time.now.usec / 1000
    pt.stop

    assert_true count >= 4
    assert_true (finish - start) > timer_msec
  rescue NotImplementedError => e
    # In an unsupported platform (MacOS)
    assert_equal "Unsupported platform", e.message
  end
end
