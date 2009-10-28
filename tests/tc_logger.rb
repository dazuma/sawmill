# -----------------------------------------------------------------------------
# 
# Sawmill: tests on the basic logger
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
    
    class TestLogger < ::Test::Unit::TestCase  # :nodoc:
      
      
      def setup
        @entries = ::Sawmill::EntryProcessor::SimpleQueue.new
        @logger = ::Sawmill::Logger.new(:processor => @entries)
        @levels = ::Sawmill::STANDARD_LEVELS
      end
      
      
      # Test basic log messages using the add method
      
      def test_add
        @logger.add(:INFO, 'Hello 1')
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:INFO), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 1', entry_.message)
        
        @logger.add(:ERROR, 'Hello 2', 'altprog')
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:ERROR), entry_.level)
        assert_equal('altprog', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 2', entry_.message)
        
        @logger.add(:WARN){ 'Hello 3' }
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:WARN), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 3', entry_.message)
        
        @logger.add(:DEBUG, 'Hello 4')
        assert_equal(0, @entries.size)
      end
      
      
      # Test convenience logging methods
      
      def test_convenience_add
        @logger.info('Hello 1')
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:INFO), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 1', entry_.message)
        
        @logger.error('altprog'){ 'Hello 2' }
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:ERROR), entry_.level)
        assert_equal('altprog', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 2', entry_.message)
        
        @logger.warn(){ 'Hello 3' }
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:WARN), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 3', entry_.message)
        
        @logger.debug('Hello 4')
        assert_equal(0, @entries.size)
        
        @logger.fatal('Hello 5')
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:FATAL), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 5', entry_.message)
        
        @logger.any('Hello 6')
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 6', entry_.message)
        
        @logger.unknown('Hello 7')
        entry_ = @entries.dequeue
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 7', entry_.message)
        
        assert_raise(::NoMethodError) do
          @logger.always('Hello 8')
        end
      end
      
      
      # Test current level queries
      
      def test_level_queries
        assert_equal(@levels.get(:INFO), @logger.level)
        assert_equal(false, @logger.debug?)
        assert_equal(true, @logger.info?)
        assert_equal(true, @logger.warn?)
        assert_equal(true, @logger.error?)
        assert_equal(true, @logger.fatal?)
        assert_equal(true, @logger.any?)
        assert_equal(true, @logger.unknown?)
        @logger.level = :ERROR
        assert_equal(@levels.get(:ERROR), @logger.level)
        assert_equal(false, @logger.debug?)
        assert_equal(false, @logger.info?)
        assert_equal(false, @logger.warn?)
        assert_equal(true, @logger.error?)
        assert_equal(true, @logger.fatal?)
        assert_equal(true, @logger.any?)
        @logger.level = ::Logger::DEBUG
        assert_equal(@levels.get(:DEBUG), @logger.level)
        assert_equal(true, @logger.debug?)
        assert_equal(true, @logger.info?)
        assert_equal(true, @logger.warn?)
        assert_equal(true, @logger.error?)
        assert_equal(true, @logger.fatal?)
        assert_equal(true, @logger.any?)
      end
      
      
      # Test setting the progname
      
      def test_setting_progname
        assert_equal('sawmill', @logger.progname)
        @logger.info('Hello 1')
        entry_ = @entries.dequeue
        assert_equal('sawmill', entry_.progname)
        assert_equal('Hello 1', entry_.message)
        @logger.progname = 'rails'
        assert_equal('rails', @logger.progname)
        @logger.info('Hello 2')
        entry_ = @entries.dequeue
        assert_equal('rails', entry_.progname)
        assert_equal('Hello 2', entry_.message)
      end
      
      
      # Test record delimiters
      
      def test_record_delimiters_auto_id
        id_ = @logger.begin_record
        @logger.info('Hello 1')
        @logger.end_record
        entry_ = @entries.dequeue
        assert_equal(:begin_record, entry_.type)
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        entry_ = @entries.dequeue
        assert_equal(:message, entry_.type)
        assert_equal(@levels.get(:INFO), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        assert_equal('Hello 1', entry_.message)
        entry_ = @entries.dequeue
        assert_equal(:end_record, entry_.type)
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        assert_equal(0, @entries.size)
      end
      
      
      # Test record delimiters
      
      def test_record_delimiters_custom_id
        @logger.begin_record('1234')
        @logger.info('Hello 2')
        @logger.end_record
        entry_ = @entries.dequeue
        assert_equal(:begin_record, entry_.type)
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal('1234', entry_.record_id)
        entry_ = @entries.dequeue
        assert_equal(:message, entry_.type)
        assert_equal(@levels.get(:INFO), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal('1234', entry_.record_id)
        assert_equal('Hello 2', entry_.message)
        entry_ = @entries.dequeue
        assert_equal(:end_record, entry_.type)
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal('1234', entry_.record_id)
        assert_equal(0, @entries.size)
      end
      
      
      # Test record delimiters
      
      def test_message_outside_record
        @logger.begin_record
        @logger.end_record
        @logger.info('Hello 3')
        entry_ = @entries.dequeue
        assert_equal(:begin_record, entry_.type)
        entry_ = @entries.dequeue
        assert_equal(:end_record, entry_.type)
        entry_ = @entries.dequeue
        assert_equal(:message, entry_.type)
        assert_equal(@levels.get(:INFO), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_nil(entry_.record_id)
        assert_equal('Hello 3', entry_.message)
        assert_equal(0, @entries.size)
      end
      
      
      # Test attribute
      
      def test_attribute
        id_ = @logger.begin_record
        @logger.set_attribute('user', 'daniel')
        @logger.end_record
        entry_ = @entries.dequeue
        assert_equal(:begin_record, entry_.type)
        assert_equal(id_, entry_.record_id)
        entry_ = @entries.dequeue
        assert_equal(:attribute, entry_.type)
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        assert_equal(:set, entry_.operation)
        assert_equal('user', entry_.key)
        assert_equal('daniel', entry_.value)
        entry_ = @entries.dequeue
        assert_equal(:end_record, entry_.type)
        assert_equal(id_, entry_.record_id)
        assert_equal(0, @entries.size)
      end
      
      
      # Test multi-attribute
      
      def test_multi_attribute
        id_ = @logger.begin_record
        @logger.append_attribute('event', 'click')
        @logger.attribute('event', 'drag', :append, :INFO)
        @logger.end_record
        entry_ = @entries.dequeue
        assert_equal(:begin_record, entry_.type)
        assert_equal(id_, entry_.record_id)
        entry_ = @entries.dequeue
        assert_equal(:attribute, entry_.type)
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        assert_equal(:append, entry_.operation)
        assert_equal('event', entry_.key)
        assert_equal('click', entry_.value)
        entry_ = @entries.dequeue
        assert_equal(:attribute, entry_.type)
        assert_equal(@levels.get(:INFO), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        assert_equal(:append, entry_.operation)
        assert_equal('event', entry_.key)
        assert_equal('drag', entry_.value)
        entry_ = @entries.dequeue
        assert_equal(:end_record, entry_.type)
        assert_equal(id_, entry_.record_id)
        assert_equal(0, @entries.size)
      end
      
      
    end
    
  end
end
