module Timer
  class POSIX
    alias run start

    def interval?
      s = __status_raw
      s["interval.sec"] != 0 || s["interval.nsec"] != 0
    end

    def stopped?
      s = __status_raw
      s["value.sec"] == 0 && s["value.nsec"] == 0
    end

    def seconds_left
      s = __status_raw
      s["value.sec"] + s["value.nsec"] / 1_000_000_000.0
    end
  end
end
