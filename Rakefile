# -*- mode: ruby; coding: utf-8 -*-

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(dir, "lib"))

require 'webservice/timeline'
require 'webservice/timeline/version'

spec = Gem::Specification.new do |s|
  s.name             = 'ws-timeline'
  s.version          = WebService::TimeLine::Version.to_version
  s.author           = 'SAWADA Tadashi'
  s.email            = 'moc.liamg.cesare+ws-timeline@gmail.com'
  s.platform         = Gem::Platform::RUBY
  s.summary          = 'API client Library for @nifty TimeLine web service'

  files = FileList["{test,lib,doc,examples}/**/*"].exclude("doc/rdoc").to_a
  files |= ['Rakefile', 'MIT-LICENSE']
  s.files            = files

  s.require_path     = 'lib'
  s.has_rdoc         = true
  s.rdoc_options     = ['--charset', 'UTF-8']
  s.extra_rdoc_files = ['README']
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end


task :default => ['clean', 'clobber', 'test', 'rdoc', 'package']


Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_gz  = true
  pkg.need_tar_bz2 = true
  pkg.need_zip     = true
end


Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/tc_*.rb']
  t.verbose = true
end


Rake::RDocTask.new('rdoc') do |t|
  t.rdoc_dir = 'doc/rdoc'
  t.rdoc_files.include('README', 'lib/**/*.rb')
  t.main = 'README'
  t.title = 'WebService::Aboutme Documentation'
end
