# -----------------------------------------------------------------------------
#
# Sawmill entry processor that checks message content.
#
# -----------------------------------------------------------------------------
# Copyright 2012 Daniel Azuma
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


    # A basic filter that knows how to check message content.
    #
    # This is a boolean processor, so it merely returns true or false based
    # on the filter result. Use this in conjunction with an If processor to
    # actually perform other actions based on the result.

    class FilterByMessage < Base


      # Create a new filter. you must provide content, which can be a
      # string or a regex.
      #
      # Recognized options include:
      #
      # [<tt>:accept_non_messages</tt>]
      #   If set to true, accepts entries that are not messages. Otherwise,
      #   if set to false or not specified, rejects such entries.

      def initialize(content_, opts_={})
        @content = content_
        @accept_non_messages = opts_[:accept_non_messages] ? true : false
      end


      def begin_record(entry_)
        @accept_non_messages
      end

      def end_record(entry_)
        @accept_non_messages
      end

      def message(entry_)
        @content === entry_.message
      end

      def attribute(entry_)
        @accept_non_messages
      end

      def unknown_data(entry_)
        @accept_non_messages
      end

      def finish
        nil
      end


    end


  end

end
