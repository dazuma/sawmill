# -----------------------------------------------------------------------------
# 
# Sawmill record processor that checks record attribute values
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
    
    
    # A record filter that checks attribute values.
    # 
    # This is a boolean processor, so it merely returns true or false based
    # on the filter result. Use this in conjunction with an If processor to
    # actually perform other actions based on the result.
    
    class FilterByAttributes < Base
      
      
      # Create a new filter. Pass the attribute names and values to check
      # as a hash.
      
      def initialize(attributes_)
        @attributes = {}
        attributes_.each{ |key_, value_| @attributes[key_.to_s] = value_ }
      end
      
      
      def record(record_)
        @attributes.each do |key_, value_|
          record_value_ = record_.attribute(key_.to_s)
          case record_value_
          when Array
            return false unless record_value_.find{ |rval_| value_ === rval_ }
          when String
            return false unless value_ === record_value_
          when nil
            return false unless value_.nil?
          end
        end
        true
      end
      
      def extra_entry(entry_)
        false
      end
      
      def close
      end
      
    end
    
    
  end
  
end
