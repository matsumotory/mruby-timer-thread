#include <mruby.h>
#include <mruby/array.h>
#include <mruby/class.h>
#include <mruby/data.h>
#include <mruby/error.h>
#include <mruby/hash.h>
#include <mruby/variable.h>

#include <errno.h>
#include <math.h>
#include <signal.h>
#include <signal.h>
#include <time.h>

#define DONE mrb_gc_arena_restore(mrb, 0);

#define MRB_TIMER_POSIX_KEY_SIGNO mrb_intern_lit(mrb, "signal")

typedef struct {
  timer_t *timer_ptr;
  int timer_signo;
} mrb_timer_posix_data;

static void mrb_timer_posix_free(mrb_state *mrb, void *p)
{
  mrb_timer_posix_data *data = (mrb_timer_posix_data *)p;
  timer_delete(*data->timer_ptr);
  mrb_free(mrb, data->timer_ptr);
  mrb_free(mrb, data);
}

static const struct mrb_data_type mrb_timer_posix_data_type = {"mrb_timer_posix_data", mrb_timer_posix_free};

static mrb_value mrb_timer_posix_init(mrb_state *mrb, mrb_value self)
{
  mrb_timer_posix_data *data;
  timer_t *timer_ptr;
  mrb_value options = mrb_nil_value();

  struct sigevent sev;
  sev.sigev_signo = 0;

  if (mrb_get_args(mrb, "|o", &options) == -1) {
    mrb_sys_fail(mrb, "mrb_get_args");
  }

  if (!mrb_nil_p(options)) {
    mrb_value signo = mrb_hash_get(mrb, options, mrb_symbol_value(MRB_TIMER_POSIX_KEY_SIGNO));
    if (mrb_fixnum_p(signo)) {
      sev.sigev_notify = SIGEV_SIGNAL;
      sev.sigev_signo = (int)mrb_fixnum(signo);
    }
  }

  data = (mrb_timer_posix_data *)DATA_PTR(self);
  if (data)
    mrb_timer_posix_free(mrb, data);

  DATA_TYPE(self) = &mrb_timer_posix_data_type;
  DATA_PTR(self) = NULL;

  data = (mrb_timer_posix_data *)mrb_malloc(mrb, sizeof(mrb_timer_posix_data));
  timer_ptr = (timer_t *)mrb_malloc(mrb, sizeof(timer_t));

  if (sev.sigev_signo == 0) {
    if (timer_create(CLOCK_REALTIME, NULL, timer_ptr) == -1) {
      mrb_sys_fail(mrb, "timer_create failed");
    }
  } else {
    if (timer_create(CLOCK_REALTIME, &sev, timer_ptr) == -1) {
      mrb_sys_fail(mrb, "timer_create failed");
    }
  }
  data->timer_ptr = timer_ptr;
  data->timer_signo = sev.sigev_signo;

  DATA_PTR(self) = data;
  return self;
}

static int mrb_set_itimerspec(mrb_int start, mrb_int start_nsec, mrb_int interval, mrb_int interval_nsec,
                              struct itimerspec *ts)
{
  if (start < 0 || interval < 0 || ts == NULL) {
    errno = EINVAL;
    return -1;
  }

  ts->it_value.tv_sec = (time_t)start;
  ts->it_value.tv_nsec = (long)start_nsec;

  ts->it_interval.tv_sec = (time_t)interval;
  ts->it_interval.tv_nsec = (long)interval_nsec;

  return 0;
}

static mrb_value mrb_timer_posix_start(mrb_state *mrb, mrb_value self)
{
  mrb_timer_posix_data *data = DATA_PTR(self);
  mrb_int start, interval = 0;
  struct itimerspec ts;

  if (mrb_get_args(mrb, "i|i", &start, &interval) == -1) {
    mrb_sys_fail(mrb, "mrb_get_args");
  }

  if (mrb_set_itimerspec(start, 0, interval, 0, &ts) == -1) {
    mrb_raise(mrb, E_ARGUMENT_ERROR, "Values must be 0 or positive");
  }

  if (timer_settime(*(data->timer_ptr), 0, &ts, NULL) == -1) {
    mrb_sys_fail(mrb, "timer_settime");
  }

  return self;
}

static mrb_value mrb_timer_posix_start_hires(mrb_state *mrb, mrb_value self)
{
  mrb_timer_posix_data *data = DATA_PTR(self);
  mrb_float start, interval = -1;
  double tmp_i, tmp_d;
  mrb_int s_sec, s_nsec, i_sec = 0, i_nsec = 0;
  struct itimerspec ts;

  if (mrb_get_args(mrb, "f|f", &start, &interval) == -1) {
    mrb_sys_fail(mrb, "mrb_get_args");
  }

  tmp_d = modf((double)start, &tmp_i);
  s_sec = (int)tmp_i;
  s_nsec = (int)(tmp_d * 1000000000.0);

  if (interval >= 0) {
    tmp_d = modf((double)interval, &tmp_i);
    i_sec = (int)tmp_i;
    i_nsec = (int)(tmp_d * 1000000000.0);
  }

  if (mrb_set_itimerspec(s_sec, s_nsec, i_sec, i_nsec, &ts) == -1) {
    mrb_raise(mrb, E_ARGUMENT_ERROR, "Values must be 0 or positive");
  }

  if (timer_settime(*(data->timer_ptr), 0, &ts, NULL) == -1) {
    mrb_sys_fail(mrb, "timer_settime");
  }

  return self;
}

static mrb_value mrb_timer_posix_stop(mrb_state *mrb, mrb_value self)
{
  mrb_timer_posix_data *data = DATA_PTR(self);
  struct itimerspec ts;
  if (mrb_set_itimerspec(0, 0, 0, 0, &ts) == -1) {
    mrb_raise(mrb, E_ARGUMENT_ERROR, "Invalid value for stop");
  }

  if (timer_settime(*(data->timer_ptr), 0, &ts, NULL) == -1) {
    mrb_sys_fail(mrb, "timer_settime");
  }

  return self;
}

static mrb_value mrb_timer_posix_status_raw(mrb_state *mrb, mrb_value self)
{
  mrb_timer_posix_data *data = DATA_PTR(self);
  struct itimerspec ts;

  if (timer_gettime(*(data->timer_ptr), &ts) == -1) {
    mrb_sys_fail(mrb, "timer_gettime");
  }

  mrb_value ret = mrb_hash_new_capa(mrb, 2);
  mrb_hash_set(mrb, ret, mrb_str_new_lit(mrb, "value.sec"), mrb_fixnum_value((mrb_int)ts.it_value.tv_sec));
  mrb_hash_set(mrb, ret, mrb_str_new_lit(mrb, "value.nsec"), mrb_fixnum_value((mrb_int)ts.it_value.tv_nsec));
  mrb_hash_set(mrb, ret, mrb_str_new_lit(mrb, "interval.sec"), mrb_fixnum_value((mrb_int)ts.it_interval.tv_sec));
  mrb_hash_set(mrb, ret, mrb_str_new_lit(mrb, "interval.nsec"), mrb_fixnum_value((mrb_int)ts.it_interval.tv_nsec));

  return ret;
}

static mrb_value mrb_timer_posix_signo(mrb_state *mrb, mrb_value self)
{
  mrb_timer_posix_data *data = DATA_PTR(self);
  return mrb_fixnum_value(data->timer_signo);
}

void mrb_mruby_timer_gem_init(mrb_state *mrb)
{
  struct RClass *timer, *posix;
  timer = mrb_define_module(mrb, "Timer");

  posix = mrb_define_class_under(mrb, timer, "POSIX", mrb->object_class);
  MRB_SET_INSTANCE_TT(posix, MRB_TT_DATA);
  mrb_define_method(mrb, posix, "initialize", mrb_timer_posix_init, MRB_ARGS_ARG(0, 1));
  mrb_define_method(mrb, posix, "start", mrb_timer_posix_start, MRB_ARGS_ARG(1, 1));
  mrb_define_method(mrb, posix, "start_hires", mrb_timer_posix_start_hires, MRB_ARGS_ARG(1, 1));
  mrb_define_method(mrb, posix, "stop", mrb_timer_posix_stop, MRB_ARGS_NONE());
  mrb_define_method(mrb, posix, "__status_raw", mrb_timer_posix_status_raw, MRB_ARGS_NONE());

  mrb_define_method(mrb, posix, "signo", mrb_timer_posix_signo, MRB_ARGS_NONE());

  DONE;
}

void mrb_mruby_timer_gem_final(mrb_state *mrb)
{
}
