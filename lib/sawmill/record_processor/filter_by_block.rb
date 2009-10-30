# -----------------------------------------------------------------------------
# 
# Sawmill record processor that calls a block
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
    
    
    # A record filter that calls a block to perform its check.
    # 
    # This is a boolean processor, so it merely returns true or false based
    # on the filter result. Use this in conjunction with an If processor to
    # actually perform other actions based on the result.
    
    class FilterByBlock < Base
      
      
      # Create a new filter. Provide the block, which should take a
      # Sawmill::Record as the parameter and return a boolean.
      # 
      # By default, extra entries always return false. Provide an
      # extra entry filter to change this behavior.
      
      def initialize(&block_)
        to_filter_record(&block_)
      end
      
      
      # Provide a block to filter records. It should take a Sawmill::Record
      # as the parameter, and return a boolean.
      
      def to_filter_record(&block_)
        @block = block_ || Proc.new{ |record_| false }
      end
      
      
      # Provide a block to filter extra entries. It should take an entry
      # object as the parameter, and return a boolean.
      
      def to_filter_extra_entry(&block_)
        @extra_entry_block = block_ || Proc.new{ |entry_| false }
      end
      
      
      def record(record_)
        @block.call(record_)
      end
      
      def extra_entry(entry_)
        @extra_entry_block.call(entry_)
      end
      
      def finish
        nil
      end
      
    end
    
    
  end
  
end
