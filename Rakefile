# -----------------------------------------------------------------------------
# 
# Sawmill Rakefile
# 
# -----------------------------------------------------------------------------
# Copyright 2009 Daniel Azuma
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------


require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rdoc/generator/darkfish'

require ::File.expand_path("#{::File.dirname(__FILE__)}/lib/sawmill.rb")


# Configuration
extra_rdoc_files_ = ['README.rdoc', 'History.rdoc']


# Default task
task :default => [:clean, :rdoc, :package, :test]


# Clean task
CLEAN.include(['doc', 'pkg'])


# Test task
::Rake::TestTask.new('test') do |task_|
  task_.pattern = 'tests/tc_*.rb'
end


# RDoc task
::Rake::RDocTask.new do |task_|
  task_.main = 'README.rdoc'
  task_.rdoc_files.include(*extra_rdoc_files_)
  task_.rdoc_files.include('lib/sawmill/**/*.rb')
  task_.rdoc_dir = 'doc'
  task_.title = "Sawmill #{::Sawmill::VERSION_STRING} documentation"
  task_.options << '-f' << 'darkfish'
end


# Gem task
gemspec_ = ::Gem::Specification.new do |s_|
  s_.name = 'sawmill'
  s_.summary = 'Sawmill is a logging and log analysis system for Ruby.'
  s_.version = ::Sawmill::VERSION_STRING
  s_.author = 'Daniel Azuma'
  s_.email = 'dazuma@gmail.com'
  s_.description = 'Sawmill is a logging and log analysis system for Ruby. It extends the basic Ruby logging facility with log records and parsing abilities.'
  s_.homepage = 'http://virtuoso.rubyforge.org/sawmill'
  s_.rubyforge_project = 'virtuoso'
  s_.required_ruby_version = '>= 1.8.6'
  s_.files = ::FileList['lib/**/*.rb', 'tests/**/*.rb', '*.rdoc', 'Rakefile'].to_a
  s_.extra_rdoc_files = extra_rdoc_files_
  s_.has_rdoc = true
  s_.test_files = ::FileList['tests/tc_*.rb']
  s_.platform = ::Gem::Platform::RUBY
  s_.add_dependency('blockenspiel', '>= 0.3.0')
  s_.add_dependency('versionomy', '>= 0.2.0')
end
::Rake::GemPackageTask.new(gemspec_) do |task_|
  task_.need_zip = false
  task_.need_tar = true
end


# Publish RDocs
desc 'Publishes RDocs to RubyForge'
task :publish_rdoc_to_rubyforge => [:rerdoc] do
  config_ = ::YAML.load(::File.read(::File.expand_path("~/.rubyforge/user-config.yml")))
  username_ = config_['username']
  sh "rsync -av --delete doc/ #{username_}@rubyforge.org:/var/www/gforge-projects/virtuoso/sawmill"
end


# Release gem ro rubyforge
task :release_gem_to_rubyforge => [:package] do |t_|
  v_ = ::ENV["VERSION"]
  abort "Must supply VERSION=x.y.z" unless v_
  if v_ != ::Sawmill::VERSION_STRING
    abort "Versions don't match: #{v_} vs #{::Sawmill::VERSION_STRING}"
  end
  gem_pkg_ = "pkg/sawmill-#{v_}.gem"
  tgz_pkg_ = "pkg/sawmill-#{v_}.tgz"
  release_notes_ = ::File.read("README.rdoc").split(/^(==.*)/)[2].strip
  release_changes_ = ::File.read("History.rdoc").split(/^(===.*)/)[1..2].join.strip
  
  require 'rubyforge'
  rf_ = ::RubyForge.new.configure
  puts "Logging in to RubyForge"
  rf_.login
  config_ = rf_.userconfig
  config_["release_notes"] = release_notes_
  config_["release_changes"] = release_changes_
  config_["preformatted"] = true
  puts "Releasing sawmill #{v_} to RubyForge"
  rf_.add_release('virtuoso', 'sawmill', v_, gem_pkg_, tgz_pkg_)
end


# Release gem to gemcutter
task :release_gem_to_gemcutter => [:package] do |t_|
  v_ = ::ENV["VERSION"]
  abort "Must supply VERSION=x.y.z" unless v_
  if v_ != ::Sawmill::VERSION_STRING
    abort "Versions don't match: #{v_} vs #{::Sawmill::VERSION_STRING}"
  end
  puts "Releasing sawmill #{v_} to GemCutter"
  `cd pkg && gem push sawmill-#{v_}.gem`
end


# Publish everything
task :release => [:release_gem_to_gemcutter, :release_gem_to_rubyforge, :publish_rdoc_to_rubyforge]
