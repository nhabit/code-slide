require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'rspec'
require 'rspec/core/rake_task' 
require 'jeweler'
require './lib/code_slide/version.rb'

task :default => :spec do
end
                              
desc "Run all specs"
RSpec::Core::RakeTask.new do | tsk |
  tsk.rspec_opts = ["--color", "--format", "n"]
end                          

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "code-slide"
  gem.executables = ['code-slide']
  gem.files = Dir.glob('lib/**/*.rb')
  gem.homepage = "http://github.com/nhabit/code-slide"
  gem.license = "MIT"
  gem.summary = "code-slide helps you preset code and/or run training courses that focus on code-development."
  gem.description = "Given a git repository that has branches numbered according to a specific scheme, code-slide lets you shift up and down a repository tree to present certain data setups. More documentation to follow!"
  gem.email = "andy.mendelsohn@nhabit.net"
  gem.authors = ["Andy Mendelsohn"]
  gem.add_runtime_dependency 'git', '> 0.1'
  gem.version = CodeSlide::Version::STRING

end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "code-slide #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
