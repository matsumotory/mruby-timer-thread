#include <mruby.h>
#include <mruby/array.h>
#include <mruby/class.h>
#include <mruby/data.h>
#include <mruby/error.h>
#include <mruby/variable.h>

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

void mrb_mruby_timer_gem_init(mrb_state *mrb)
{
  struct RClass *timer, *posix;
  timer = mrb_define_module(mrb, "Timer");

  posix = mrb_define_class_under(mrb, timer, "POSIX", mrb->object_class);
  MRB_SET_INSTANCE_TT(posix, MRB_TT_DATA);
  mrb_define_method(mrb, posix, "initialize", mrb_timer_posix_init, MRB_ARGS_NONE());
}

void mrb_mruby_timer_gem_final(mrb_state *mrb)
{
}
