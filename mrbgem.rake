MRuby::Gem::Specification.new('mruby-timer-thread') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.cc.flags << "-DMRB_THREAD_COPY_VALUES"
  spec.add_dependency 'mruby-thread'
  spec.add_dependency 'mruby-sleep'
  spec.add_dependency 'mruby-signal-thread'
  spec.add_dependency 'mruby-process'
  spec.add_test_dependency 'mruby-sleep'
  spec.add_test_dependency 'mruby-process'
  spec.add_test_dependency 'mruby-time'

  if RUBY_PLATFORM !~ /darwin/
    spec.linker.libraries << 'rt'
  end
end
