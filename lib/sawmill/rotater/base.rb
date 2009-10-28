# -----------------------------------------------------------------------------
# 
# Sawmill formatter utility
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
  
  class Rotater
    
    
    # This class defines the rotation strategy contract. Classes that
    # implement rotation strategies need not subclass this base class, but
    # must implement the methods defined here.
    # 
    # This base class itself merely writes to STDOUT and does not do
    # any rotation.
    
    class Base
      
      
      # Return the currently preferred handle, identifying which io stream
      # should be written to preferentially unless a channel is constrained
      # to use an earlier stream.
      
      def preferred_handle
        0
      end
      
      
      # Open and return an IO object for the given handle.
      # This is guaranteed not to be called twice unless the stream has been
      # closed in the meantime.
      
      def open_handle(handle_)
        ::STDOUT
      end
      
      
      # Close the IO object for the given handle.
      # This is guaranteed not be called unless the stream has been opened.
      
      def close_handle(handle_, io_)
      end
      
      
      # This is a hook that is called before every write request to any
      # stream managed by this rotater. You may optionally perform any
      # periodic tasks here, such as renaming log files.
      
      def before_write
      end
      
      
    end
    
    
  end
  
end
