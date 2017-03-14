assert("POSIX.new") do
  t = Timer::POSIX.new
  assert_equal Timer::POSIX, t.class
end
