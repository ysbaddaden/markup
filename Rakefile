require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => :test

desc 'Test Markup.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.title = "Markup"
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rdoc.options << "--charset=utf-8"
end

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    root_files = FileList["README.rdoc"]
    gem.name = "alml"
    gem.version = "0.1.0"
    gem.summary = "Another Lightweight Markup Language."
    gem.email = "ysbaddaden@gmail.com"
    gem.homepage = "http://github.com/ysbaddaden/markup"
    gem.description = "Another Lightweight Markup Language."
    gem.authors = ['Julien Portalier']
    gem.files = root_files + FileList["{lib}/*"] + FileList["{lib}/**/*"]
    gem.extra_rdoc_files = root_files
    gem.add_dependency 'activesupport', '~> 3.0.7'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end

