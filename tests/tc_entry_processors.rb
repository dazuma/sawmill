# -----------------------------------------------------------------------------
# 
# Sawmill: tests on entry processors
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


require 'test/unit'
require ::File.expand_path("#{::File.dirname(__FILE__)}/../lib/sawmill.rb")


module Sawmill
  module Tests  # :nodoc:
    
    class TestEntryProcessors < ::Test::Unit::TestCase  # :nodoc:
      
      
      def setup
        @entries = ::Sawmill::EntryProcessor::SimpleQueue.new
        @levels = ::Sawmill::STANDARD_LEVELS
      end
      
      
      # Test a basic filter that checks the level
      
      def test_basic_level_filter
        processor_ = ::Sawmill::EntryProcessor::build do
          If(FilterBasicFields(:level => :WARN), @entries)
        end
        @logger = ::Sawmill::Logger.new(:processor => processor_)
        @logger.warn('Hello 1')
        @logger.info('Hello 2')
        @logger.error('Hello 3')
        assert_equal('Hello 1', @entries.dequeue.message)
        assert_equal('Hello 3', @entries.dequeue.message)
        assert_equal(0, @entries.size)
      end
      
      
      # Test a basic filter that checks the progname
      
      def test_basic_progname_filter
        processor_ = ::Sawmill::EntryProcessor::build do
          If(FilterBasicFields(:progname => 'rails'), @entries)
        end
        @logger = ::Sawmill::Logger.new(:processor => processor_)
        @logger.info('Hello 1')
        @logger.info('rails') {'Hello 2'}
        @logger.info('Hello 3')
        assert_equal('Hello 2', @entries.dequeue.message)
        assert_equal(0, @entries.size)
      end
      
      
      # Test an "AND" filter
      
      def test_conjunction_and
        processor_ = ::Sawmill::EntryProcessor::build do
          If(And(FilterBasicFields(:progname => 'rails'),
                 FilterBasicFields(:level => :WARN)), @entries)
        end
        @logger = ::Sawmill::Logger.new(:processor => processor_)
        @logger.warn('Hello 1')
        @logger.warn('rails') {'Hello 2'}
        @logger.info('rails') {'Hello 3'}
        @logger.info('Hello 4')
        assert_equal('Hello 2', @entries.dequeue.message)
        assert_equal(0, @entries.size)
      end
      
      
      # Test an "OR" filter
      
      def test_conjunction_or
        processor_ = ::Sawmill::EntryProcessor::build do
          If(Or(FilterBasicFields(:progname => 'rails'),
                FilterBasicFields(:level => :WARN)), @entries)
        end
        @logger = ::Sawmill::Logger.new(:processor => processor_)
        @logger.warn('Hello 1')
        @logger.warn('rails') {'Hello 2'}
        @logger.info('rails') {'Hello 3'}
        @logger.info('Hello 4')
        assert_equal('Hello 1', @entries.dequeue.message)
        assert_equal('Hello 2', @entries.dequeue.message)
        assert_equal('Hello 3', @entries.dequeue.message)
        assert_equal(0, @entries.size)
      end
      
      
      # Test a "NOT" filter
      
      def test_boolean_not
        processor_ = ::Sawmill::EntryProcessor::build do
          If(Not(FilterBasicFields(:progname => 'rails')), @entries)
        end
        @logger = ::Sawmill::Logger.new(:processor => processor_)
        @logger.info('Hello 1')
        @logger.info('rails') {'Hello 2'}
        @logger.info('sawmill') {'Hello 3'}
        assert_equal('Hello 1', @entries.dequeue.message)
        assert_equal('Hello 3', @entries.dequeue.message)
        assert_equal(0, @entries.size)
      end
      
      
    end
    
  end
end
