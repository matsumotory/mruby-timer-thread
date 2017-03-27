assert("Timer::POSIX.new") do
  t = Timer::POSIX.new
  assert_equal Timer::POSIX, t.class
end

assert("Timer::POSIX#run") do
  timer_msec = 200

  pt = Timer::POSIX.new(signal: nil)
  begin
    start = Time.now.to_i * 1000 + Time.now.usec / 1000
    pt.run timer_msec

    while pt.running? do
      usleep 1000
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

    while pt1.running? do
      usleep 1000
    end
    assert_true !pt1.running? && pt2.running?

    while pt2.running? do
      usleep 1000
    end
    finish = Time.now.to_i * 1000 + Time.now.usec / 1000
    assert_true (finish - start) > (timer_msec + gap_msec)
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

    while pts.any? {|pt| pt.running? } do
      usleep 1000
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
    while count < 4 do
      usleep 1000
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
