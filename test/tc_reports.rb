# -----------------------------------------------------------------------------
# 
# Sawmill: tests reports
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
require 'stringio'
require ::File.expand_path("#{::File.dirname(__FILE__)}/../lib/sawmill.rb")


module Sawmill
  module Tests  # :nodoc:
    
    class TestMultiParser < ::Test::Unit::TestCase  # :nodoc:
      
      
      def setup
        @levels = ::Sawmill::STANDARD_LEVELS
      end
      
      
      # Test entry report.
      
      def test_entry_report
        processor_ = EntryProcessor.build do
          CompileReport(If(FilterByBasicFields(:level => :WARN),
                           CountEntries(:label => 'warn: ')),
                        If(FilterByBasicFields(:level => :ERROR),
                           CountEntries(:label => 'error: ')))
        end
        logger_ = Logger.new(:processor => processor_)
        logger_.info("hello 1")
        logger_.warn("hello 2")
        logger_.info("hello 3")
        logger_.error("hello 4")
        logger_.fatal("hello 5")
        logger_.info("hello 6")
        assert_equal("warn: 3\nerror: 2", logger_.close)
      end
      
      
      # Test record report.
      
      def test_record_report
        processor_ = RecordProcessor.build do
          CompileReport(If(FilterByAttributes('user' => 'daniel'),
                           CountRecords(:label => 'daniel: ')),
                        If(FilterByAttributes('location' => 'seattle'),
                           CountRecords(:label => 'seattle: ')))
        end
        logger_ = Logger.new(:processor => Sawmill::RecordBuilder.new(processor_))
        logger_.begin_record
        logger_.set_attribute('user', 'daniel')
        logger_.set_attribute('location', 'tacoma')
        logger_.end_record
        logger_.begin_record
        logger_.set_attribute('user', 'daniel')
        logger_.set_attribute('location', 'seattle')
        logger_.end_record
        logger_.begin_record
        logger_.set_attribute('user', 'bill')
        logger_.set_attribute('location', 'tacoma')
        logger_.end_record
        assert_equal("daniel: 2\nseattle: 1", logger_.close)
      end
      
      
    end
    
  end
end
