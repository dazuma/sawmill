# -----------------------------------------------------------------------------
# 
# Sawmill entry stream processor interface
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
    
    
    # A simple queue that optionally provides an upper size limit.
    
    class Queue
      
      
      # Recognized options include:
      # 
      # <tt>:limit</tt>::
      #   Size limit for the queue. If not specified, the queue can grow
      #   arbitrarily large.
      # <tt>:drop_oldest</tt>::
      #   If set to true, then when an item is added to a full queue, the
      #   oldest item is dropped. If set to false or not specified, then
      #   the new item is not added.
      
      def initialize(opts_={})
        limit_ = opts_[:limit]
        @buffer = limit_ ? ::Array.new(limit_) : []
        @push_ptr = limit_ ? 0 : nil
        @pop_ptr = nil
        @drop_oldest = limit_ && opts_[:drop_oldest]
      end
      
      
      # Attempt to push an item on the queue.
      # 
      # If the queue is full, then the behavior is determined by the
      # :drop_oldest setting provided to the constructor.
      # 
      # Returns true if the object was pushed on the queue, or false if the
      # queue was full.
      
      def enqueue(object_)
        result_ = true
        if @push_ptr
          if @pop_ptr == @push_ptr
            if @drop_oldest
              @pop_ptr += 1
              @pop_ptr = 0 if @pop_ptr == @buffer.size
              result_ = false
            else
              return false
            end
          elsif @pop_ptr.nil?
            @pop_ptr = @push_ptr
          end
          @buffer[@push_ptr] = object_
          @push_ptr += 1
          @push_ptr = 0 if @push_ptr == @buffer.size
        else
          @buffer.push(object_)
        end
        result_
      end
      
      
      # Return the oldest item in the queue, or nil if the queue is empty.
      
      def dequeue
        if @push_ptr
          if @pop_ptr
            object_ = @buffer[@pop_ptr]
            @pop_ptr += 1
            @pop_ptr = 0 if @pop_ptr == @buffer.size
            @pop_ptr = nil if @pop_ptr == @push_ptr
            object_
          else
            nil
          end
        else
          @buffer.shift
        end
      end
      
      
      # Return the size of the queue, which is 0 if the queue is empty.
      
      def size
        if @push_ptr
          if @pop_ptr
            value_ = @push_ptr - @pop_ptr
            value_ > 0 ? value_ : value_ + @buffer.size
          else
            0
          end
        else
          @buffer.size
        end
      end
      
      
    end
    
    
  end
  
end
