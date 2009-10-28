# -----------------------------------------------------------------------------
# 
# Sawmill: tests log file formatting and parsing
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
require 'stringio'
require ::File.expand_path("#{::File.dirname(__FILE__)}/../lib/sawmill.rb")


module Sawmill
  module Tests  # :nodoc:
    
    class TestFormatterParser < ::Test::Unit::TestCase  # :nodoc:
      
      
      def setup
        @entries = []
        @levels = ::Sawmill::STANDARD_LEVELS
      end
      
      
      def _run_test(expected_, opts_={})
        stringio_ = ::StringIO.new
        formatter_ = ::Sawmill::EntryClassifier.new(::Sawmill::Formatter.new(stringio_, opts_))
        @entries.each do |entry_|
          formatter_.entry(entry_)
        end
        formatted_string_ = stringio_.string
        assert_equal(expected_, formatted_string_)
        stringio_ = ::StringIO.new(formatted_string_)
        parser_ = ::Sawmill::Parser.new(stringio_, nil)
        @entries.each do |expected_|
          assert_equal(expected_, parser_.parse_one_entry)
        end
      end
      
      
      # Test message entry
      
      def test_basic_message
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 120000), 'rails', nil, 'Hello')
        _run_test("[INFO 2009-10-20 08:30:45.12 rails .] Hello\n")
      end
      
      
      # Test message with no fractional seconds
      
      def test_message_with_whole_seconds
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 0), 'rails', nil, 'Hello')
        _run_test("[INFO 2009-10-20 08:30:45.00 rails .] Hello\n")
      end
      
      
      # Test multiple message entry
      
      def test_multiple_messages
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 120000), 'rails', nil, 'Hello')
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:ERROR), Time.utc(2009, 10, 20, 8, 30, 46, 980000), 'rails', nil, 'Something bad happened!')
        _run_test("[INFO 2009-10-20 08:30:45.12 rails .] Hello\n[ERROR 2009-10-20 08:30:46.98 rails .] Something bad happened!\n")
      end
      
      
      # Test multi-line message entries
      
      def test_multi_line_messages
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 120000), 'rails', nil, "Multiple\nLines\n")
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:ERROR), Time.utc(2009, 10, 20, 8, 30, 46, 980000), 'rails', nil, "Multiple Lines\\\nwith trailing backslashes\\\\\n")
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:ERROR), Time.utc(2009, 10, 20, 8, 30, 47, 0), 'rails', nil, "More trailing\\\nbackslashes\\\\")
        _run_test("[INFO 2009-10-20 08:30:45.12 rails .] Multiple\\\nLines\\\n\n[ERROR 2009-10-20 08:30:46.98 rails .] Multiple Lines\\\\\\\nwith trailing backslashes\\\\\\\\\\\n\n[ERROR 2009-10-20 08:30:47.00 rails .] More trailing\\\\\\\nbackslashes\\\\\\\\\n")
      end
      
      
      # Test record delimiter entries
      
      def test_record_delimiters
        @entries << ::Sawmill::Entry::BeginRecord.new(@levels.get(:ANY), Time.utc(2009, 10, 20, 8, 30, 45, 120000), 'rails', 'abcdefg')
        @entries << ::Sawmill::Entry::EndRecord.new(@levels.get(:ANY), Time.utc(2009, 10, 20, 8, 30, 46, 980000), 'rails', 'abcdefg')
        _run_test("[ANY 2009-10-20 08:30:45.12 rails ^] BEGIN abcdefg\n[ANY 2009-10-20 08:30:46.98 rails $] END abcdefg\n")
      end
      
      
      # Test attribute entries
      
      def test_attributes
        @entries << ::Sawmill::Entry::BeginRecord.new(@levels.get(:ANY), Time.utc(2009, 10, 20, 8, 30, 45, 110000), 'rails', 'abcdefg')
        @entries << ::Sawmill::Entry::Attribute.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 120000), 'rails', 'abcdefg', 'SIZE', 'small')
        @entries << ::Sawmill::Entry::Attribute.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 46, 980000), 'rails', 'abcdefg', 'COLOR', "red\nand\nblue", :append)
        @entries << ::Sawmill::Entry::EndRecord.new(@levels.get(:ANY), Time.utc(2009, 10, 20, 8, 30, 46, 990000), 'rails', 'abcdefg')
        _run_test("[ANY 2009-10-20 08:30:45.11 rails ^] BEGIN abcdefg\n[INFO 2009-10-20 08:30:45.12 rails =] SIZE = small\n[INFO 2009-10-20 08:30:46.98 rails =] COLOR + red\\\nand\\\nblue\n[ANY 2009-10-20 08:30:46.99 rails $] END abcdefg\n")
      end
      
      
      # Test message with include_id
      
      def test_message_with_include_id
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 0), 'rails', 'abcdefg', 'Hello 1')
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 100000), 'rails', nil, 'Hello 2')
        _run_test("[INFO 2009-10-20 08:30:45.00 rails abcdefg .] Hello 1\n[INFO 2009-10-20 08:30:45.10 rails .] Hello 2\n", :include_id => true)
      end
      
      
      # Test message where fractional seconds are turned off
      
      def test_message_without_fractional_seconds
        @entries << ::Sawmill::Entry::Message.new(@levels.get(:INFO), Time.utc(2009, 10, 20, 8, 30, 45, 0), 'rails', nil, 'Hello 1')
        _run_test("[INFO 2009-10-20 08:30:45 rails .] Hello 1\n", :fractional_second_digits => 0)
      end
      
      
    end
    
  end
end
