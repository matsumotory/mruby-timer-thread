MRuby::Gem::Specification.new('mruby-timer') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  #spec.add_dependency 'mruby-thread', github: 'mattn/mruby-thread', checksum_hash: '2c33681e7f4a536f2be926f0ee2b287d5b11569b'
  spec.add_dependency 'mruby-sleep'
  spec.add_dependency 'mruby-signal'
  spec.add_dependency 'mruby-process'
  spec.add_test_dependency 'mruby-sleep'
  spec.add_test_dependency 'mruby-signal'
  spec.add_test_dependency 'mruby-process'

  spec.linker.libraries << 'rt'
end
