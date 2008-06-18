require 'rubygems'
require 'rake'
require 'rake/gempackagetask'

gemspecWindows = Gem::Specification.new do |s| 
  s.platform = Gem::Platform::WIN32
  s.name = "xftp"
  s.version = "1.00"
  s.summary = "Upload video files to an xbox running XBMC."
  s.files = FileList["{lib,ext}/**/*"].to_a
  s.executables = 'xftp'
  s.require_path = "lib"
  s.test_files = FileList["{test}/**/*",'Rakefile'].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = 'README'
  s.author = "Darren Hinderer"
  s.email = "darren.hinderer@gmail.com"
end

gemspecLinux = Gem::Specification.new do |s| 
  s.platform = Gem::Platform::RUBY
  s.name = "xftp"
  s.version = "1.00"
  s.summary = "Upload video files to an xbox running XBMC."
  s.files = FileList["{lib}/**/*"].to_a
  s.executables = "xftp"
  s.require_path = "lib"
  s.bindir = "bin"
  s.test_files = FileList["{test}/**/*",'Rakefile'].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = 'README'
  s.author = "Darren Hinderer"
  s.email = "darren.hinderer@gmail.com"
end

task :build do
  Gem::Builder.new(gemspecWindows).build
  Gem::Builder.new(gemspecLinux).build
end
