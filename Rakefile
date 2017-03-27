MRUBY_CONFIG=File.expand_path(ENV["MRUBY_CONFIG"] || "build_config.rb")
MRUBY_VERSION=ENV["MRUBY_VERSION"] || "master"

file :mruby do
  sh "git clone --depth=1 git://github.com/mruby/mruby.git"
end

desc "compile binary"
task :compile => :mruby do
  sh "cd mruby && rake all MRUBY_CONFIG=\"#{MRUBY_CONFIG}\""
end

desc "memtest"
task :memtest => :compile do
  sh %q<valgrind ./mruby/bin/mruby -e '100.times {t = Timer::POSIX.new(signal: nil) ; t.start 100, 100}'>
end

desc "test"
task :test => :mruby do
  sh "cd mruby && rake all test MRUBY_CONFIG=\"#{MRUBY_CONFIG}\""
end

desc "cleanup"
task :clean do
  sh "cd mruby && rake deep_clean"
end

task :default => :compile
