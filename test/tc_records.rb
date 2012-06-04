# -----------------------------------------------------------------------------
# 
# Sawmill: tests on log record construction
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
require 'test/unit'
require 'set'
require ::File.expand_path("#{::File.dirname(__FILE__)}/../lib/sawmill.rb")


module Sawmill
  module Tests  # :nodoc:
    
    class TestRecords < ::Test::Unit::TestCase  # :nodoc:
      
      
      def setup
        @records = ::Sawmill::RecordProcessor::SimpleQueue.new
        @logger = ::Sawmill::Logger.new(:processor => ::Sawmill::RecordBuilder.new(@records))
        @levels = ::Sawmill::STANDARD_LEVELS
      end
      
      
      # Test basic record creation
      
      def test_basic_create
        id_ = @logger.begin_record
        @logger.end_record
        record_ = @records.dequeue
        assert(record_.started?)
        assert(record_.complete?)
        assert_equal(id_, record_.record_id)
        assert_equal(0, record_.message_count)
        assert_equal(2, record_.entry_count)
        entries_ = record_.all_entries
        assert_equal(:begin_record, entries_[0].type)
        assert_equal(@levels.get(:ANY), entries_[0].level)
        assert_equal('sawmill', entries_[0].progname)
        assert_equal(id_, entries_[0].record_id)
        assert_equal(:end_record, entries_[1].type)
        assert_equal(@levels.get(:ANY), entries_[1].level)
        assert_equal('sawmill', entries_[1].progname)
        assert_equal(id_, entries_[1].record_id)
      end
      
      
      # Test record messages
      
      def test_messages
        id_ = @logger.begin_record
        @logger.info('Hello 1')
        @logger.error('rails'){ 'Hello 2' }
        @logger.end_record
        record_ = @records.dequeue
        assert_equal(2, record_.message_count)
        assert_equal(4, record_.entry_count)
        meessages_ = record_.all_messages
        assert_equal(:message, meessages_[0].type)
        assert_equal(@levels.get(:INFO), meessages_[0].level)
        assert_equal('sawmill', meessages_[0].progname)
        assert_equal(id_, meessages_[0].record_id)
        assert_equal('Hello 1', meessages_[0].message)
        assert_equal(:message, meessages_[1].type)
        assert_equal(@levels.get(:ERROR), meessages_[1].level)
        assert_equal('rails', meessages_[1].progname)
        assert_equal(id_, meessages_[1].record_id)
        assert_equal('Hello 2', meessages_[1].message)
      end
      
      
      # Test record attributes
      
      def test_attributes
        @logger.begin_record
        @logger.attribute('color', 'blue')
        @logger.attribute('size', 'small')
        @logger.attribute(:color, 'red')
        @logger.end_record
        record_ = @records.dequeue
        assert_equal(0, record_.message_count)
        assert_equal(5, record_.entry_count)
        assert_equal(::Set.new(['color', 'size']), ::Set.new(record_.attribute_keys))
        assert_equal('small', record_.attribute('size'))
        assert_equal('red', record_.attribute('color'))
      end
      
      
      # Test record multi-attributes
      
      def test_multi_attributes
        @logger.begin_record
        @logger.append_attribute('color', 'blue')
        @logger.append_attribute('size', 'small')
        @logger.append_attribute(:color, 'red')
        @logger.end_record
        record_ = @records.dequeue
        assert_equal(0, record_.message_count)
        assert_equal(5, record_.entry_count)
        assert_equal(::Set.new(['color', 'size']), ::Set.new(record_.attribute_keys))
        assert_equal(['small'], record_.attribute('size'))
        assert_equal(['blue', 'red'], record_.attribute('color'))
      end
      
      
      # Test record decomposition
      
      def _test_decompose
        entries_ = ::Sawmill::EntryProcessor::SimpleQueue.new
        id_ = @logger.begin_record
        @logger.info('Hello 1')
        @logger.attribute('color', 'blue')
        @logger.attribute('size', 'small')
        @logger.multi_attribute('shape', 'round')
        @logger.error('rails'){ 'Hello 2' }
        @logger.attribute(:color, 'red')
        @logger.multi_attribute('shape', 'pointy')
        @logger.end_record
        record_ = @records.dequeue
        assert_equal(9, record_.entry_count)
        record_.decompose(entries_)
        
        entry_ = entries_.dequeue
        assert_equal(:begin_record, entry_.type)
        assert_equal(@levels.get(:ANY), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        
        entry_ = entries_.dequeue
        assert_equal(:message, entry_.type)
        assert_equal(@levels.get(:INFO), entry_.level)
        assert_equal('sawmill', entry_.progname)
        assert_equal(id_, entry_.record_id)
        assert_equal('Hello 1', entry_.message)
        
        entry_ = entries_.dequeue
        assert_equal(:attribute, entry_.type)
        assert_equal('color', entry_.key)
        assert_equal('blue', entry_.value)
        
        entry_ = entries_.dequeue
        assert_equal(:attribute, entry_.type)
        assert_equal('size', entry_.key)
        assert_equal('small', entry_.value)
        
        entry_ = entries_.dequeue
        assert_equal(:multi_attribute, entry_.type)
        assert_equal('shape', entry_.key)
        assert_equal('round', entry_.value)
        
        entry_ = entries_.dequeue
        assert_equal(:message, entry_.type)
        assert_equal(@levels.get(:ERROR), entry_.level)
        assert_equal('rails', entry_.progname)
        assert_equal('Hello 2', entry_.message)
        
        entry_ = entries_.dequeue
        assert_equal(:attribute, entry_.type)
        assert_equal('color', entry_.key)
        assert_equal('red', entry_.value)
        
        entry_ = entries_.dequeue
        assert_equal(:multi_attribute, entry_.type)
        assert_equal('shape', entry_.key)
        assert_equal('pointy', entry_.value)
        
        entry_ = entries_.dequeue
        assert_equal(:end_record, entry_.type)
        assert_equal(id_, entry_.record_id)
        
        assert_equal(0, entries_.size)
      end
      
      
    end
    
  end
end
