# -----------------------------------------------------------------------------
#
# Sawmill entry processor that generates reports
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


    # This processor reports the number of entries processed.

    class CountEntries < Base


      # Create a count-entries report.
      #
      # Recognized options include:
      #
      # [<tt>:label</tt>]
      #   Label to use for the report.
      #   If provided, the report is returned as a string of the form
      #   "#{label}#{value}"
      #   If set to nil or absent, the report is returned as an integer.
      # [<tt>:omit_unknown_data</tt>]
      #   If set to true, omits unknown_data from the count.
      #   Default is false.
      # [<tt>:omit_attributes</tt>]
      #   If set to true, omits attributes from the count.
      #   Default is false.
      # [<tt>:omit_record_delimiters</tt>]
      #   If set to true, omits begin_record and end_record from the count.
      #   Default is false.

      def initialize(opts_={})
        @label = opts_[:label]
        @omit_unknown_data = opts_[:omit_unknown_data]
        @omit_attributes = opts_[:omit_attributes]
        @omit_record_delimiters = opts_[:omit_record_delimiters]
        @finished = false
        @count = 0
      end


      def begin_record(entry_)
        @count += 1 unless @finished || @omit_record_delimiters
        true
      end

      def end_record(entry_)
        @count += 1 unless @finished || @omit_record_delimiters
        true
      end

      def message(entry_)
        @count += 1 unless @finished
        true
      end

      def attribute(entry_)
        @count += 1 unless @finished || @omit_attributes
        true
      end

      def unknown_data(entry_)
        @count += 1 unless @finished || @omit_unknown_data
        true
      end

      def finish
        @finished = true
        @label ? "#{@label}#{@count}" : @count
      end


    end


  end

end
