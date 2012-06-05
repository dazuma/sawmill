# -----------------------------------------------------------------------------
#
# Sawmill: tests multi-parser
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


      def _get_io_array(entry_groups_)
        strings_ = []
        entry_groups_.each do |entries_|
          stringio_ = ::StringIO.new
          formatter_ = ::Sawmill::EntryClassifier.new(::Sawmill::Formatter.new(stringio_, :fractional_second_digits => 6))
          entries_.each do |entry_|
            formatter_.entry(entry_)
          end
          strings_ << stringio_.string
        end
        strings_.map{ |str_| ::StringIO.new(str_) }
      end


      # Test interleaved entries including unknown data entries.
      # Makes sure they come out in the right order.

      def test_interleaved_entries
        base_time_ = ::Time.gm(2012, 3, 14, 15, 9, 27)
        entries_ = []
        2.times do |i_|
          entries_ << ::Sawmill::Entry::UnknownData.new("Unknown #{i_}")
        end
        4.times do |i_|
          entries_ << ::Sawmill::Entry::Message.new(@levels.get(:INFO), base_time_+i_, 'rails', nil, "Hello #{i_}")
        end
        io_array_ = _get_io_array([[entries_[0], entries_[2], entries_[5]], [entries_[3], entries_[4], entries_[1]]])
        queue_ = ::Sawmill::EntryProcessor::SimpleQueue.new
        ::Sawmill::MultiParser.new(io_array_, queue_).parse_all
        assert_equal([entries_[0], entries_[2], entries_[3], entries_[4], entries_[1], entries_[5]], queue_.dequeue_all)
      end


    end

  end
end
