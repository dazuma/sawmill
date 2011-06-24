# -----------------------------------------------------------------------------
# 
# Sawmill record processor queues log records
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
    
    
    # This processor simply queues up log records for later use.
    
    class SimpleQueue < Base
      
      
      # Create a queue. This processor actually maintains two separate
      # queues, one for records and another for extra entries.
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
        @extra_entries_queue = Util::Queue.new(opts_)
        @closed = false
      end
      
      
      # Return the oldest record in the record queue, or nil if the record
      # queue is empty.
      
      def dequeue
        @queue.dequeue
      end
      
      
      # Return an array of the contents of the record queue, in order.
      
      def dequeue_all
        @queue.dequeue_all
      end
      
      
      # Return the number of records in the record queue.
      
      def size
        @queue.size
      end
      
      
      # Return the oldest entry in the extra entry queue, or nil if the
      # extra entry queue is empty.
      
      def dequeue_extra_entry
        @extra_entries_queue.dequeue
      end
      
      
      # Return an array of the contents of the extra entry queue, in order.
      
      def dequeue_all_extra_entries
        @extra_entries_queue.dequeue_all
      end
      
      
      # Return the number of entries in the extra entry queue.
      
      def extra_entries_size
        @extra_entries_queue.size
      end
      
      
      def record(record_)
        @queue.enqueue(record_) unless @closed
      end
      
      def extra_entry(entry_)
        @extra_entries_queue.enqueue(entry_) unless @closed
      end
      
      def finish
        @closed = true
        nil
      end
      
      
    end
    
    
  end
  
  
end
