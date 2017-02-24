timer = TimerThread.new

Signal.trap(:USR1) do |signo|
  puts "catch signal from timer thread"
  while !timer.running? do
    puts "finish main thread"
    exit 1
  end
end

timer.run_with_signal 3000, :USR1

puts "waiting timer"
loop { sleep 1 }
