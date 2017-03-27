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
