# -----------------------------------------------------------------------------
#
# Sawmill: tests on the levels mechanism
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
require 'logger'
require ::File.expand_path("#{::File.dirname(__FILE__)}/../lib/sawmill.rb")


module Sawmill
  module Tests  # :nodoc:

    class TestLevels < ::Test::Unit::TestCase  # :nodoc:


      def setup
        @levels = ::Sawmill::STANDARD_LEVELS
      end


      # Test equivalence of standard level names and legacy logger level constants

      def test_standard_names_vs_legacy_constants
        assert_equal(@levels.get(:DEBUG), @levels.get(::Logger::DEBUG))
        assert_not_equal(@levels.get(:DEBUG), @levels.get(::Logger::INFO))
        assert_equal(@levels.get(:INFO), @levels.get(::Logger::INFO))
        assert_equal(@levels.get(:WARN), @levels.get(::Logger::WARN))
        assert_equal(@levels.get(:ERROR), @levels.get(::Logger::ERROR))
        assert_equal(@levels.get(:FATAL), @levels.get(::Logger::FATAL))
        assert_equal(@levels.get(:ANY), @levels.get(::Logger::UNKNOWN))
      end


      # Test special levels in the standard set

      def test_special_standard_levels
        assert_equal(@levels.get(:DEBUG), @levels.lowest)
        assert_equal(@levels.get(:INFO), @levels.default)
        assert_equal(@levels.get(:ANY), @levels.highest)
        assert_equal(@levels.get(nil), @levels.default)
      end


      # Test method lookup of standard levels

      def test_standard_method_lookup
        assert_equal(@levels.get(:DEBUG), @levels.lookup_method(:debug))
        assert_equal(@levels.get(:INFO), @levels.lookup_method(:info))
        assert_equal(@levels.get(:WARN), @levels.lookup_method(:warn))
        assert_equal(@levels.get(:ERROR), @levels.lookup_method(:error))
        assert_equal(@levels.get(:FATAL), @levels.lookup_method(:fatal))
        assert_equal(@levels.get(:ANY), @levels.lookup_method(:any))
        assert_equal(@levels.get(:ANY), @levels.lookup_method(:unknown))
      end


      # Test comparison of standard levels

      def test_standard_comparisons
        assert(@levels.get(:DEBUG) < @levels.get(:INFO))
        assert(@levels.get(:ANY) > @levels.get(:FATAL))
        assert(@levels.get(:ERROR) >= @levels.get(:DEBUG))
        assert(@levels.get(:WARN) >= @levels.get(:WARN))
      end


      # Test custom level group

      def test_custom_group
        group_ = ::Sawmill::LevelGroup.new do |g_|
          g_.add(:LOW, :methods => 'low')
          g_.add(:MED, :methods => 'med', :default => true)
          g_.add(:HIGH, :methods => 'high')
          g_.add(:CRIT, :methods => 'crit')
        end
        assert_equal(group_.get(:LOW), group_.get(0))
        assert_equal(group_.get(:HIGH), group_.get(2))
        assert_equal(group_.default, group_.get(1))
        assert_equal(group_.highest, group_.get(3))
        assert_not_equal(@levels.lowest, group_.lowest)
      end


    end

  end
end
