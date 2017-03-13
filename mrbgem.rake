MRuby::Gem::Specification.new('mruby-timer') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.add_dependency 'mruby-thread'
  spec.add_dependency 'mruby-sleep'
  spec.add_dependency 'mruby-signal-thread'
  spec.add_dependency 'mruby-process'

  spec.add_test_dependency 'mruby-sleep'
  spec.add_test_dependency 'mruby-process'
end
