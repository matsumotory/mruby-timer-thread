#include <mruby.h>

void mrb_mruby_timer_gem_init(mrb_state *mrb)
{
    struct RClass *timer;
    timer = mrb_define_module(mrb, "Timer");
}

void mrb_mruby_timer_gem_final(mrb_state *mrb)
{
}
