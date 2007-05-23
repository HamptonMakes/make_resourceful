require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the make_resourceful plugin.'
task :test do
  Dir.chdir(File.dirname(__FILE__) + '/test')
  tests = IO.popen('rake test')

  while byte = tests.read(1)
    print byte
  end
end

desc 'Generate documentation for the make_resourceful plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'make_resourceful'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
