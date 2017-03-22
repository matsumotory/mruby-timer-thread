timer = TimerThread.new

SignalThread.trap(:USR1) do
  puts "catch signal from timer thread"

  while timer.running? do
    sleep 1
  end

  puts "finish main thread"
  exit 1
end

timer.run_with_signal 3000, :USR1

puts "waiting timer"
loop {
  sleep 1
}
