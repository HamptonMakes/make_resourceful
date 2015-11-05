require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

spec_files = Rake::FileList["spec/**/*_spec.rb"]

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = ["-c"]
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.spec_files = spec_files
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/var/lib/gems']
end

desc 'Generate documentation for the make_resourceful plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'make_resourceful'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.main = 'README'
  rdoc.rdoc_files.include(FileList.new('*').exclude(/[^A-Z0-9]/))
  rdoc.rdoc_files.include('lib/**/*.rb')
end
