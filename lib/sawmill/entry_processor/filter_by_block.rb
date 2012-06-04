# -----------------------------------------------------------------------------
#
# Sawmill entry processor that calls a block
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


    # A entry filter that calls a block to perform its check.
    #
    # This is a boolean processor, so it merely returns true or false based
    # on the filter result. Use this in conjunction with an If processor to
    # actually perform other actions based on the result.

    class FilterByBlock < Base


      # Create a new filter. Provide the block, which should take an entry
      # object as the parameter and return a boolean.

      def initialize(&block_)
        to_filter_entry(&block_)
      end


      # Provide a block to filter entries. It should take an entry object
      # as the parameter, and return a boolean.

      def to_filter_entry(&block_)
        @block = block_ || Proc.new{ |entry_| false }
      end


      def begin_record(entry_)
        @block.call(entry_)
      end

      def end_record(entry_)
        @block.call(entry_)
      end

      def message(entry_)
        @block.call(entry_)
      end

      def attribute(entry_)
        @block.call(entry_)
      end

      def unknown_data(entry_)
        @block.call(entry_)
      end

      def finish
        nil
      end

    end


  end

end
