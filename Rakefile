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



require 'rubygems'


module RAKEFILE
  
  DLEXT = ::Config::CONFIG['DLEXT']
  PLATFORM =
    case ::RUBY_DESCRIPTION
    when /^jruby\s/ then :jruby
    when /^ruby\s/ then :mri
    when /^rubinius\s/ then :rubinius
    else :unknown
    end
  PLATFORM_SUFFIX =
    case PLATFORM
    when :mri
      if ::RUBY_VERSION =~ /^1\.8\..*$/
        'mri18'
      elsif ::RUBY_VERSION =~ /^1\.9\..*$/
        'mri19'
      else
        raise "Unknown version of Matz Ruby Interpreter (#{::RUBY_VERSION})"
      end
    when :rubinius then 'rbx'
    when :jruby then 'jruby'
    else 'unknown'
    end
  
  PRODUCT_NAME = 'sawmill'
  PRODUCT_VERSION = ::File.read(::File.dirname(__FILE__)+'/Version').strip.freeze
  RUBYFORGE_PROJECT = 'virtuoso'
  
  SOURCE_FILES = ::Dir.glob('lib/**/*.rb')
  
  EXTRA_RDOC_FILES = ::Dir.glob('*.rdoc')
  ALL_RDOC_FILES = SOURCE_FILES + EXTRA_RDOC_FILES
  MAIN_RDOC_FILE = 'README.rdoc'
  RDOC_TITLE = "Sawmill #{PRODUCT_VERSION} Documentation"
  
  TEST_FILES = ::Dir.glob('tests/**/*.rb')
  
  DOC_DIRECTORY = 'doc'
  PKG_DIRECTORY = 'pkg'
  
  CLEAN_PATTERNS = [DOC_DIRECTORY, PKG_DIRECTORY, 'tmp', '**/*.rbc']
  
  GEMSPEC = ::Gem::Specification.new do |s_|
    s_.name = PRODUCT_NAME
    s_.summary = "Sawmill is a logging and log analysis system for Ruby."
    s_.description = "Sawmill is a logging and log analysis system for Ruby. It extends the basic Ruby logging facility with log records and parsing abilities."
    s_.version = "#{PRODUCT_VERSION}"
    s_.author = 'Daniel Azuma'
    s_.email = 'dazuma@gmail.com'
    s_.homepage = "http://#{RUBYFORGE_PROJECT}.rubyforge.org/#{PRODUCT_NAME}"
    s_.rubyforge_project = RUBYFORGE_PROJECT
    s_.required_ruby_version = '>= 1.8.7'
    s_.files = SOURCE_FILES + EXTRA_RDOC_FILES + TEST_FILES + ['Version']
    s_.extra_rdoc_files = EXTRA_RDOC_FILES
    s_.has_rdoc = true
    s_.test_files = TEST_FILES
    s_.platform = ::Gem::Platform::RUBY
    s_.add_dependency('blockenspiel', '>= 0.4.1')
  end
  
end


task :clean do
  ::RAKEFILE::CLEAN_PATTERNS.each do |pattern_|
    ::Dir.glob(pattern_) do |path_|
      rm_r path_ rescue nil
    end
  end
end


task :build_rdoc => "#{::RAKEFILE::DOC_DIRECTORY}/index.html"
file "#{::RAKEFILE::DOC_DIRECTORY}/index.html" => ::RAKEFILE::ALL_RDOC_FILES do
  rm_r ::RAKEFILE::DOC_DIRECTORY rescue nil
  args_ = []
  args_ << '-o' << ::RAKEFILE::DOC_DIRECTORY
  args_ << '--main' << ::RAKEFILE::MAIN_RDOC_FILE
  args_ << '--title' << ::RAKEFILE::RDOC_TITLE
  args_ << '-f' << 'darkfish'
  require 'rdoc'
  require 'rdoc/rdoc'
  require 'rdoc/generator/darkfish'
  ::RDoc::RDoc.new.document(args_ + ::RAKEFILE::ALL_RDOC_FILES)
end


task :publish_rdoc => :build_rdoc do
  config_ = ::YAML.load(::File.read(::File.expand_path("~/.rubyforge/user-config.yml")))
  username_ = config_['username']
  sh "rsync -av --delete #{::RAKEFILE::DOC_DIRECTORY}/ #{username_}@rubyforge.org:/var/www/gforge-projects/#{::RAKEFILE::RUBYFORGE_PROJECT}/#{::RAKEFILE::PRODUCT_NAME}"
end


task :build_gem do
  ::Gem::Builder.new(::RAKEFILE::GEMSPEC).build
  mkdir_p ::RAKEFILE::PKG_DIRECTORY
  mv "#{::RAKEFILE::PRODUCT_NAME}-#{::RAKEFILE::PRODUCT_VERSION}.gem", "#{::RAKEFILE::PKG_DIRECTORY}/"
end


task :release_gem => [:build_gem] do
  ::Dir.chdir(::RAKEFILE::PKG_DIRECTORY) do
    sh "#{::RbConfig::TOPDIR}/bin/gem push #{::RAKEFILE::PRODUCT_NAME}-#{::RAKEFILE::PRODUCT_VERSION}.gem"
  end
end


task :test do
  $:.unshift(::File.expand_path('lib', ::File.dirname(__FILE__)))
  ::RAKEFILE::TEST_FILES.each do |path_|
    load path_
    puts "Loaded testcase #{path_}"
  end
end


task :default => [:clean, :build_rdoc, :build_gem, :test]
