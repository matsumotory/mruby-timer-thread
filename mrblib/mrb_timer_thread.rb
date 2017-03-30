class TimerThread
  def initialize retry_timer_usec = 1000
    # TODO
    @timer_thread = nil
    @timer_interval_usec = 1000
  end

  def timer_proc(timer)
    Proc.new do
      loop_time = 0
      # calculate by usec
      while loop_time < timer * 1000
        loop_time += usleep @timer_interval_usec
      end
    end
  end

  def run msec_timer
    @timer_thread = Thread.new timer_proc(msec_timer) do |timer|
      timer.call
    end
  end

  def run_with_signal msec_timer, signal, tid
    sigstr = signal.to_s
    sig = Proc.new do
      timer_proc(msec_timer).call
      SignalThread.kill_by_tid tid, sigstr
    end

    # thread attach another mrb_state, so need msec_timer arg
    @timer_thread = Thread.new sig do |signal_timer|
      signal_timer.call
    end
  end

  def running?
    @timer_thread.alive?
  end

  def blocking_handler
    @timer_thread.join
    yield
  end
end

module Timer
  MRubyThread = TimerThread
end
