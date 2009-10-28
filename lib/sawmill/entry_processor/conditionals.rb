# -----------------------------------------------------------------------------
# 
# Sawmill basic entry processors that implement conditionals
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
;


module Sawmill
  
  module EntryProcessor
    
    
    # An "if" conditional.
    # 
    # Takes a boolean condition processor and executes a processor on true
    # (and optionally another one on false).
    # 
    # For example, this builds a processor that sends formatted log entries
    # to STDOUT only if their level is at least INFO:
    # 
    #  processor = Sawmill::EntryProcessor.build do
    #    If(FilterBasicFields(:level => :INFO), Format(STDOUT))
    #  end
    
    class If < Base
      
      
      # Create an "if" conditional.
      # 
      # The first parameter must be a processor whose methods return a
      # boolean value indicating whether the entry should be accepted.
      # The second parameter is a processor to run on accepted entries.
      # The optional third parameter is an "else" processor to run on
      # rejected entries.
      
      def initialize(condition_, on_true_, on_false_=nil)
        @condition = condition_
        @on_true = on_true_
        @on_false = on_false_
      end
      
      def begin_record(entry_)
        if @condition.begin_record(entry_)
          @on_true.begin_record(entry_)
        elsif @on_false
          @on_false.begin_record(entry_)
        end
      end
      
      def end_record(entry_)
        if @condition.end_record(entry_)
          @on_true.end_record(entry_)
        elsif @on_false
          @on_false.end_record(entry_)
        end
      end
      
      def message(entry_)
        if @condition.message(entry_)
          @on_true.message(entry_)
        elsif @on_false
          @on_false.message(entry_)
        end
      end
      
      def attribute(entry_)
        if @condition.attribute(entry_)
          @on_true.attribute(entry_)
        elsif @on_false
          @on_false.attribute(entry_)
        end
      end
      
      def unknown_data(entry_)
        if @condition.unknown_data(entry_)
          @on_true.unknown_data(entry_)
        elsif @on_false
          @on_false.unknown_data(entry_)
        end
      end
      
      def close
        @on_true.close
        @on_false.close if @on_false
      end
    
      
    end
    
    
    # A boolean processor that returns the boolean negation of a given
    # processor.
    # 
    # For example, this builds a processor that sends formatted log entries
    # to STDOUT only if their level is NOT at least INFO:
    # 
    #  processor = Sawmill::EntryProcessor.build do
    #    If(Not(FilterBasicFields(:level => :INFO)), Format(STDOUT))
    #  end
    
    class Not < Base
      
      
      # Create a "not" boolean.
      # The parameter is a boolean processor to run. This processor returns
      # the boolean negation of its output.
      
      def initialize(child_)
        @child = _interpret_processor(child_)
      end
      
      def begin_record(entry_)
        !@child.begin_record(entry_)
      end
      
      def end_record(entry_)
        !@child.end_record(entry_)
      end
      
      def message(entry_)
        !@child.message(entry_)
      end
      
      def attribute(entry_)
        !@child.attribute(entry_)
      end
      
      def unknown_data(entry_)
        !@child.unknown_data(entry_)
      end
      
      def close
        @child.close
      end
    
      
    end
    
    
    # A boolean processor that returns true if and only if all its child
    # processors return true. This version short-circuits the processing,
    # so once one child returns false, subsequent children are not called
    # at all.
    # 
    # For example, this builds a processor that sends formatted log entries
    # to STDOUT only if their level is at least INFO AND the progname is
    # is "rails":
    # 
    #  processor = Sawmill::EntryProcessor.build do
    #    If(And(FilterBasicFields(:level => :INFO),
    #           FilterBasicFields(:progname => 'rails')),
    #       Format(STDOUT))
    #  end
    
    class And < Base
      
      
      # Create an "and" boolean.
      # The parameters are child processors whose return values should be
      # combined with an AND operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def begin_record(entry_)
        @children.each do |child_|
          return false unless child_.begin_record(entry_)
        end
        true
      end
      
      def end_record(entry_)
        @children.each do |child_|
          return false unless child_.end_record(entry_)
        end
        true
      end
      
      def message(entry_)
        @children.each do |child_|
          return false unless child_.message(entry_)
        end
        true
      end
      
      def attribute(entry_)
        @children.each do |child_|
          return false unless child_.attribute(entry_)
        end
        true
      end
      
      def unknown_data(entry_)
        @children.each do |child_|
          return false unless child_.unknown_data(entry_)
        end
        true
      end
      
      def close
        @children.each{ |forward_| forward_.close }
      end
    
      
    end
    
    
    # A boolean processor that returns true if and only if any of its child
    # processors returns true. This version short-circuits the processing,
    # so once one child returns true, subsequent children are not called
    # at all.
    # 
    # For example, this builds a processor that sends formatted log entries
    # to STDOUT only if their level is at least INFO OR the progname is
    # "rails":
    # 
    #  processor = Sawmill::EntryProcessor.build do
    #    If(Or(FilterBasicFields(:level => :INFO),
    #          FilterBasicFields(:progname => 'rails')),
    #       Format(STDOUT))
    #  end
    
    class Or < Base
      
      
      # Create an "or" boolean.
      # The parameters are child processors whose return values should be
      # combined with an OR operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def begin_record(entry_)
        @children.each do |child_|
          return true if child_.begin_record(entry_)
        end
        false
      end
      
      def end_record(entry_)
        @children.each do |child_|
          return true if child_.end_record(entry_)
        end
        false
      end
      
      def message(entry_)
        @children.each do |child_|
          return true if child_.message(entry_)
        end
        false
      end
      
      def attribute(entry_)
        @children.each do |child_|
          return true if child_.attribute(entry_)
        end
        false
      end
      
      def unknown_data(entry_)
        @children.each do |child_|
          return true if child_.unknown_data(entry_)
        end
        false
      end
      
      def close
        @children.each{ |forward_| forward_.close }
      end
    
      
    end
    
    
    # A boolean processor that returns true if and only if all its child
    # processors return true. This version does not short-circuit the
    # processing, so all children are always called even if an early one
    # returns false. Thus, this processor is also a good one to use as a
    # multiplexor to simply run a bunch of processors.
    # 
    # For example, this builds a processor that sends formatted log entries
    # to STDOUT only if their level is at least INFO AND the progname is
    # "rails":
    # 
    #  processor = Sawmill::EntryProcessor.build do
    #    If(All(FilterBasicFields(:level => :INFO),
    #           FilterBasicFields(:progname => 'rails')),
    #       Format(STDOUT))
    #  end
    # 
    # This processor just formats both to STDOUT and STDERR:
    # 
    #  processor = Sawmill::EntryProcessor.build do
    #    All(Format(STDOUT), Format(STDERR))
    #  end
    
    class All < Base
      
      
      # Create an "all" boolean.
      # The parameters are child processors whose return values should be
      # combined with an AND operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def begin_record(entry_)
        @children.inject(true) do |result_, child_|
          child_.begin_record(entry_) && result_
        end
      end
      
      def end_record(entry_)
        @children.inject(true) do |result_, child_|
          child_.end_record(entry_) && result_
        end
      end
      
      def message(entry_)
        @children.inject(true) do |result_, child_|
          child_.message(entry_) && result_
        end
      end
      
      def attribute(entry_)
        @children.inject(true) do |result_, child_|
          child_.attribute(entry_) && result_
        end
      end
      
      def unknown_data(entry_)
        @children.inject(true) do |result_, child_|
          child_.unknown_data(entry_) && result_
        end
      end
      
      def close
        @children.each{ |forward_| forward_.close }
      end
    
      
    end
    
    
    # A boolean processor that returns true if and only if any of its child
    # processors returns true. This version does not short-circuit the
    # processing, so all children are always called even if an early one
    # returns true.
    # 
    # For example, this builds a processor that sends formatted log entries
    # to STDOUT only if their level is at least INFO OR the progname is
    # "rails":
    # 
    #  processor = Sawmill::EntryProcessor.build do
    #    If(Any(FilterBasicFields(:level => :INFO),
    #           FilterBasicFields(:progname => 'rails')),
    #       Format(STDOUT))
    #  end
    
    class Any < Base
      
      
      # Create an "any" boolean.
      # The parameters are child processors whose return values should be
      # combined with an OR operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def begin_record(entry_)
        @children.inject(false) do |result_, child_|
          child_.begin_record(entry_) || result_
        end
      end
      
      def end_record(entry_)
        @children.inject(false) do |result_, child_|
          child_.end_record(entry_) || result_
        end
      end
      
      def message(entry_)
        @children.inject(false) do |result_, child_|
          child_.message(entry_) || result_
        end
      end
      
      def attribute(entry_)
        @children.inject(false) do |result_, child_|
          child_.attribute(entry_) || result_
        end
      end
      
      def unknown_data(entry_)
        @children.inject(false) do |result_, child_|
          child_.unknown_data(entry_) || result_
        end
      end
      
      def close
        @children.each{ |forward_| forward_.close }
      end
    
      
    end
    
    
  end
  
end
