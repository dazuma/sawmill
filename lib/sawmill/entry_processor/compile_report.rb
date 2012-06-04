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


    # This processor collects and formats reports from descendant
    # entry processors.

    class CompileReport < All


      # Create a report collection.
      #
      # Recognized options include:
      #
      # [<tt>:postprocessor</tt>]
      #   Postprocessor proc for individual reports.
      #   See to_postprocess_value.
      # [<tt>:separator</tt>]
      #   Separator string to be inserted between individual reports.
      #   Default is a single newline.
      # [<tt>:header</tt>]
      #   Header string for the final compiled report.
      #   Default is the empty string.
      # [<tt>:footer</tt>]
      #   Footer string for the final compiled report.
      #   Default is the empty string.

      def initialize(*children_)
        opts_ = children_.last.kind_of?(::Hash) ? children_.pop : {}
        @postprocessor = opts_[:postprocessor]
        @separator = opts_[:separator] || "\n"
        @header = opts_[:header] || ''
        @footer = opts_[:footer] || ''
        super(*children_)
      end


      # Separator string to be inserted between individual reports.
      attr_accessor :separator

      # Header string for the final compiled report.
      attr_accessor :header

      # Footer string for the final compiled report.
      attr_accessor :footer


      # Provide a postprocessor block for individual report values.
      # This block should take a single parameter and return a string
      # that should be included in the compiled report. It may also
      # return nil to indicate that the data should not be included.

      def to_postprocess_value(&block_)
        @postprocessor = block_
      end


      # On finish, this processor calls finish on its descendants, converts
      # their values into strings and compiles them into a report. It then
      # returns that report as a string.

      def finish
        values_ = super || []
        values_ = [values_] unless values_.kind_of?(::Array)
        values_.map!{ |val_| @postprocessor.call(val_) } if @postprocessor
        values_.compact!
        "#{@header}#{values_.join(@separator)}#{@footer}"
      end


    end


  end


end
