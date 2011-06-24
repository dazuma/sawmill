# -----------------------------------------------------------------------------
# 
# Sawmill entry processor that queues entries
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
    
    
    # This processor simply queues up log entries for later use.
    
    class SimpleQueue < Base
      
      
      # Create a queue.
      # 
      # Recognized options include:
      # 
      # [<tt>:limit</tt>]
      #   Size limit for the queue. If not specified, the queue can grow
      #   arbitrarily large.
      # [<tt>:drop_oldest</tt>]
      #   If set to true, then when an item is added to a full queue, the
      #   oldest item is dropped. If set to false or not specified, then
      #   the new item is not added.
      
      def initialize(opts_={})
        @queue = Util::Queue.new(opts_)
        @closed = false
      end
      
      
      # Return the oldest entry in the queue, or nil if the queue is empty.
      
      def dequeue
        @queue.dequeue
      end
      
      
      # Return an array of the contents of the queue, in order.
      
      def dequeue_all
        @queue.dequeue_all
      end
      
      
      # Return the size of the queue, which is 0 if the queue is empty.
      
      def size
        @queue.size
      end
      
      
      def begin_record(entry_)
        @queue.enqueue(entry_) unless @closed
        !@closed
      end
      
      def end_record(entry_)
        @queue.enqueue(entry_) unless @closed
        !@closed
      end
      
      def message(entry_)
        @queue.enqueue(entry_) unless @closed
        !@closed
      end
      
      def attribute(entry_)
        @queue.enqueue(entry_) unless @closed
        !@closed
      end
      
      def unknown_data(entry_)
        @queue.enqueue(entry_) unless @closed
        !@closed
      end
      
      def finish
        @closed = true
        nil
      end
      
      
    end
    
    
  end
  
  
end
