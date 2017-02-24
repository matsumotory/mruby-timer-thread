class TimerThread
  def initialize retry_timer_usec = 1000
    # TODO
    @timer_thread = nil
    @timer_interval_usec = 1000
  end

  def run msec_timer
    # thread attach another mrb_state, so need msec_timer arg
    @timer_thread = Thread.new msec_timer, @timer_interval_usec do |timer, interval|
      loop_time = 0
      # calculate by usec
      while loop_time < timer * 1000
        loop_time += usleep interval
      end
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
