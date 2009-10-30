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
  
  module RecordProcessor
    
    
    # An "if" conditional.
    # 
    # Takes a boolean condition processor and executes a processor on true
    # (and optionally another one on false).
    # 
    # For example, this builds a processor that sends formatted log records
    # to STDOUT only if they have a "user" attribute of "daniel":
    # 
    #  processor = Sawmill::RecordProcessor.build do
    #    If(FilterByAttributes('user' => 'daniel'), Format(STDOUT))
    #  end
    
    class If < Base
      
      
      # Create an "if" conditional.
      # 
      # The first parameter must be a processor whose methods return a
      # boolean value indicating whether the record should be accepted.
      # The second parameter is a processor to run on accepted records.
      # The optional third parameter is an "else" processor to run on
      # rejected records.
      
      def initialize(condition_, on_true_, on_false_=nil)
        @condition = condition_
        @on_true = on_true_
        @on_false = on_false_
      end
      
      def record(record_)
        if @condition.record(record_)
          @on_true.record(record_)
        elsif @on_false
          @on_false.record(record_)
        end
      end
      
      def extra_entry(entry_)
        if @condition.extra_entry(entry_)
          @on_true.extra_entry(entry_)
        elsif @on_false
          @on_false.extra_entry(entry_)
        end
      end
      
      def finish
        Util::ProcessorTools.collect_finish_values([@on_true, @on_false])
      end
      
      
    end
    
    
    # A boolean processor that returns the boolean negation of a given
    # processor.
    # 
    # For example, this builds a processor that sends formatted log records
    # to STDOUT only if they do NOT have a "user" attribute of "daniel":
    # 
    #  processor = Sawmill::RecordProcessor.build do
    #    If(Not(FilterByAttributes('user' => 'daniel')), Format(STDOUT))
    #  end
    
    class Not < Base
      
      
      # Create a "not" boolean.
      # The parameter is a boolean processor to run. This processor returns
      # the boolean negation of its output.
      
      def initialize(child_)
        @child = _interpret_processor(child_)
      end
      
      def record(record_)
        !@child.record(record_)
      end
      
      def extra_entry(entry_)
        !@child.extra_entry(record_)
      end
      
      def finish
        @child.finish
      end
      
      
    end
    
    
    # A boolean processor that returns true if and only if all its child
    # processors return true. This version short-circuits the processing,
    # so once one child returns false, subsequent children are not called
    # at all.
    # 
    # For example, this builds a processor that sends formatted log records
    # to STDOUT only if they have a "user" attribute of "daniel" AND their
    # record ID is '12345678':
    # 
    #  processor = Sawmill::RecordProcessor.build do
    #    If(And(FilterByAttributes('user' => 'daniel'),
    #           FilterByRecordID('12345678')),
    #       Format(STDOUT))
    #  end
    
    class And < Base
      
      
      # Create an "and" boolean.
      # The parameters are child processors whose return values should be
      # combined with an AND operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def record(record_)
        @children.each do |child_|
          return false unless child_.record(record_)
        end
        true
      end
      
      def extra_entry(entry_)
        @children.each do |child_|
          return false unless child_.extra_entry(entry_)
        end
        true
      end
      
      def finish
        Util::ProcessorTools.collect_finish_values(@children)
      end
      
      
    end
    
    
    # A boolean processor that returns true if and only if any of its child
    # processors returns true. This version short-circuits the processing,
    # so once one child returns true, subsequent children are not called
    # at all.
    # 
    # For example, this builds a processor that sends formatted log records
    # to STDOUT only if they have a "user" attribute of "daniel" OR their
    # record ID is '12345678':
    # 
    #  processor = Sawmill::RecordProcessor.build do
    #    If(Or(FilterByAttributes('user' => 'daniel'),
    #          FilterByRecordID('12345678')),
    #       Format(STDOUT))
    #  end
    
    class Or < Base
      
      
      # Create an "or" boolean.
      # The parameters are child processors whose return values should be
      # combined with an OR operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def record(record_)
        @children.each do |child_|
          return true if child_.record(record_)
        end
        false
      end
      
      def extra_entry(entry_)
        @children.each do |child_|
          return true if child_.extra_entry(entry_)
        end
        false
      end
      
      def finish
        Util::ProcessorTools.collect_finish_values(@children)
      end
      
      
    end
    
    
    # A boolean processor that returns true if and only if all its child
    # processors return true. This version does not short-circuit the
    # processing, so all children are always called even if an early one
    # returns false. Thus, this processor is also a good one to use as a
    # multiplexor to simply run a bunch of processors.
    # 
    # For example, this builds a processor that sends formatted log records
    # to STDOUT only if they have a "user" attribute of "daniel" AND their
    # record ID is '12345678':
    # 
    #  processor = Sawmill::RecordProcessor.build do
    #    If(All(FilterByAttributes('user' => 'daniel'),
    #           FilterByRecordID('12345678')),
    #       Format(STDOUT))
    #  end
    # 
    # This processor just formats both to STDOUT and STDERR:
    # 
    #  processor = Sawmill::RecordProcessor.build do
    #    All(Format(STDOUT), Format(STDERR))
    #  end
    
    class All < Base
      
      
      # Create an "all" boolean.
      # The parameters are child processors whose return values should be
      # combined with an AND operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def record(record_)
        @children.inject(true) do |result_, child_|
          child_.record(record_) && result_
        end
      end
      
      def extra_entry(entry_)
        @children.inject(true) do |result_, child_|
          child_.extra_entry(entry_) && result_
        end
      end
      
      def finish
        Util::ProcessorTools.collect_finish_values(@children)
      end
      
      
    end
    
    
    # A boolean processor that returns true if and only if any of its child
    # processors returns true. This version does not short-circuit the
    # processing, so all children are always called even if an early one
    # returns true.
    # 
    # For example, this builds a processor that sends formatted log records
    # to STDOUT only if they have a "user" attribute of "daniel" OR their
    # record ID is '12345678':
    # 
    #  processor = Sawmill::RecordProcessor.build do
    #    If(Any(FilterByAttributes('user' => 'daniel'),
    #           FilterByRecordID('12345678')),
    #       Format(STDOUT))
    #  end
    
    class Any < Base
      
      
      # Create an "any" boolean.
      # The parameters are child processors whose return values should be
      # combined with an OR operation.
      
      def initialize(*children_)
        @children = _interpret_processor_array(children_)
      end
      
      def record(record_)
        @children.inject(false) do |result_, child_|
          child_.record(record_) || result_
        end
      end
      
      def extra_entry(entry_)
        @children.inject(false) do |result_, child_|
          child_.extra_entry(entry_) || result_
        end
      end
      
      def finish
        Util::ProcessorTools.collect_finish_values(@children)
      end
      
      
    end
    
    
  end
  
end
