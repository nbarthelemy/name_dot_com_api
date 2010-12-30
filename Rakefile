require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

# Added to get the specs working
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec)

task :default => :spec
task :specs => :spec

# Generate documentation
require 'rake/rdoctask'
desc "Generate Documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'Name.com API'
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'Name.com API'
  rdoc.rdoc_files.include(FileList[ 'lib/**/*.rb', 'README.rdoc', 'LICENSE'])
end