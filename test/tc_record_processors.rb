# -----------------------------------------------------------------------------
#
# Sawmill: tests on record processors
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
require ::File.expand_path("#{::File.dirname(__FILE__)}/../lib/sawmill.rb")


module Sawmill
  module Tests  # :nodoc:

    class TestRecordProcessors < ::Test::Unit::TestCase  # :nodoc:


      def setup
        @records = ::Sawmill::RecordProcessor::SimpleQueue.new
        @levels = ::Sawmill::STANDARD_LEVELS
      end


      # Test a basic filter that checks the record ID

      def test_basic_record_id_filter
        processor_ = ::Sawmill::RecordProcessor::build do
          If(FilterByRecordID('12345678'), @records)
        end
        @logger = ::Sawmill::Logger.new(:processor => ::Sawmill::RecordBuilder.new(processor_))
        @logger.begin_record('asdf')
        @logger.end_record
        @logger.begin_record('12345678')
        @logger.end_record
        @logger.begin_record('qwerty')
        @logger.end_record
        assert_equal('12345678', @records.dequeue.record_id)
        assert_equal(0, @records.size)
      end


      # Test a basic filter that checks an attribute

      def test_basic_attribute_filter
        processor_ = ::Sawmill::RecordProcessor::build do
          If(FilterByAttributes('user' => 'daniel'), @records)
        end
        @logger = ::Sawmill::Logger.new(:processor => ::Sawmill::RecordBuilder.new(processor_))
        @logger.begin_record('1')
        @logger.attribute('user', 'bill')
        @logger.end_record
        @logger.begin_record('2')
        @logger.attribute('user', 'daniel')
        @logger.end_record
        @logger.begin_record('3')
        @logger.attribute('admin', 'daniel')
        @logger.end_record
        assert_equal('2', @records.dequeue.record_id)
        assert_equal(0, @records.size)
      end


      # Test a basic filter that checks two attributes

      def test_two_attributes_filter
        processor_ = ::Sawmill::RecordProcessor::build do
          If(FilterByAttributes('user' => 'daniel', 'type' => 'admin'), @records)
        end
        @logger = ::Sawmill::Logger.new(:processor => ::Sawmill::RecordBuilder.new(processor_))
        @logger.begin_record('1')
        @logger.attribute('user', 'bill')
        @logger.attribute('type', 'admin')
        @logger.end_record
        @logger.begin_record('2')
        @logger.attribute('user', 'daniel')
        @logger.end_record
        @logger.begin_record('3')
        @logger.attribute('user', 'daniel')
        @logger.attribute('type', 'admin')
        @logger.end_record
        assert_equal('3', @records.dequeue.record_id)
        assert_equal(0, @records.size)
      end


    end

  end
end
