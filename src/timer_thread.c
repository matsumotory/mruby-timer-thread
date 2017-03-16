#include <mruby.h>
#include <mruby/array.h>
#include <mruby/class.h>
#include <mruby/data.h>
#include <mruby/error.h>
#include <mruby/hash.h>
#include <mruby/variable.h>

#include <errno.h>
#include <signal.h>
#include <time.h>

#define DONE mrb_gc_arena_restore(mrb, 0);

typedef struct {
  timer_t *timer_ptr;
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
  data = (mrb_timer_posix_data *)DATA_PTR(self);
  if (data)
    mrb_timer_posix_free(mrb, data);

  DATA_TYPE(self) = &mrb_timer_posix_data_type;
  DATA_PTR(self) = NULL;

  data = (mrb_timer_posix_data *)mrb_malloc(mrb, sizeof(mrb_timer_posix_data));
  timer_ptr = (timer_t *)mrb_malloc(mrb, sizeof(timer_t));
  if (timer_create(CLOCK_REALTIME, NULL, timer_ptr) == -1) {
    mrb_sys_fail(mrb, "timer_create failed");
  }
  data->timer_ptr = timer_ptr;

  DATA_PTR(self) = data;
  return self;
}

static int mrb_set_itmerspec(mrb_int start, mrb_int interval, struct itimerspec *ts)
{
  if (start < 0 || interval < 0 || ts == NULL) {
    errno = EINVAL;
    return -1;
  }

  ts->it_value.tv_sec = (time_t)start;
  ts->it_value.tv_nsec = 0L;

  ts->it_interval.tv_sec = (time_t)interval;
  ts->it_interval.tv_nsec = 0L;

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

  if (mrb_set_itmerspec(start, interval, &ts) == -1) {
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
  if (mrb_set_itmerspec(0, 0, &ts) == -1) {
    mrb_raise(mrb, E_ARGUMENT_ERROR, "Invalid value for stop");
  }

  if (timer_settime(*(data->timer_ptr), 0, &ts, NULL) == -1) {
    mrb_sys_fail(mrb, "timer_settime");
  }

  return self;
}

#define MRB_TIMER_RES_SEC mrb_intern_lit(mrb, ":sec")
#define MRB_TIMER_RES_MSEC mrb_intern_lit(mrb, ":msec")

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

void mrb_mruby_timer_gem_init(mrb_state *mrb)
{
  struct RClass *timer, *posix;
  timer = mrb_define_module(mrb, "Timer");

  posix = mrb_define_class_under(mrb, timer, "POSIX", mrb->object_class);
  MRB_SET_INSTANCE_TT(posix, MRB_TT_DATA);
  mrb_define_method(mrb, posix, "initialize", mrb_timer_posix_init, MRB_ARGS_NONE());
  mrb_define_method(mrb, posix, "start", mrb_timer_posix_start, MRB_ARGS_ARG(1, 2));
  mrb_define_method(mrb, posix, "stop", mrb_timer_posix_stop, MRB_ARGS_NONE());
  mrb_define_method(mrb, posix, "__status_raw", mrb_timer_posix_status_raw, MRB_ARGS_NONE());
}

void mrb_mruby_timer_gem_final(mrb_state *mrb)
{
}
