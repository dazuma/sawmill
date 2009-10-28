# -----------------------------------------------------------------------------
# 
# Sawmill heap utility
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
  
  module Util
    
    
    # A simple heap class.
    
    class Heap
      
      
      # Create a new heap.
      
      def initialize(data_=nil, &block_)
        @_heap = data_ || []
        @_comparator = block_ || Proc.new{ |a_,b_| a_ <=> b_ }
      end
      
      
      def merge(enum_)
        enum_.each{ |value_| add(value_) }
        self
      end
      
      
      def add(value_)
        @_heap << value_
        _sift_up(@_heap.length-1)
        self
      end
      
      
      def <<(value_)
        add(value_)
      end
      
      
      def remove
        ret_ = @_heap[0]
        if @_heap.length > 1
          @_heap[0] = @_heap.pop
          _sift_down(0)
        else
          @_heap.clear
        end
        ret_
      end
      
      
      def peek
        @_heap[0]
      end
      
      
      def size
        @_heap.size
      end
      
      
      def empty?
        @_heap.empty?
      end
      
      
      def clear
        @_heap.clear
      end
      
      
      def each!
        while !empty?
          yield(remove)
        end
      end
      
      
      private
      
      def _sift_up(start_)  # :nodoc:
        while start_ > 0
          parent_ = (start_ + 1) / 2 - 1
          if @_comparator.call(@_heap[start_], @_heap[parent_]) < 0
            @_heap[start_], @_heap[parent_] = @_heap[parent_], @_heap[start_]
            start_ = parent_
          else
            return start_
          end
        end
      end
      
      
      def _sift_down(start_)  # :nodoc:
        length_ = self.size
        while length_ >= (child2_ = (start_ + 1) * 2)
          child1_ = child2_-1
          if length_ <= child2_
            earliest_child_ = child1_
          elsif @_comparator.call(@_heap[child1_], @_heap[child2_]) < 0
            earliest_child_ = child1_
          else
            earliest_child_ = child2_
          end
          if @_comparator.call(@_heap[start_], @_heap[earliest_child_]) < 0
            return start_
          else
            @_heap[start_], @_heap[earliest_child_] = @_heap[earliest_child_], @_heap[start_]
            start_ = earliest_child_
          end
        end
      end
      
      
    end
    
    
  end
  
end
