# -----------------------------------------------------------------------------
#
# Sawmill record processor that formats for log files
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


    # This processor formats log records and writes them to a destination.

    class Format < Base


      # Create a formatter.
      #
      # The destination can be a ruby IO object, a Sawmill::Rotater, or any
      # object that responds to the "write" and "close" methods as defined
      # by the ruby IO class.
      #
      # Recognized options include:
      #
      # [<tt>:include_id</tt>]
      #   Include the record ID in every log entry. Default is false.
      # [<tt>:fractional_second_digits</tt>]
      #   Number of digits of fractional seconds to display in timestamps.
      #   Default is 2. Accepted values are 0 to 6.
      # [<tt>:level_width</tt>]
      #   Column width of the level field.
      # [<tt>:entry_length_limit</tt>]
      #   Limit to the entry length. Entries are truncated to this length
      #   when written. If not specified, entries are not truncated.

      def initialize(destination_, opts_={})
        if (entry_length_limit_ = opts_.delete(:entry_length_limit))
          opts_ = opts_.merge(:length_limit => entry_length_limit_)
        end
        @formatter = EntryProcessor::Format.new(destination_, opts_)
        @classifier = EntryClassifier.new(@formatter)
      end


      def record(record_)
        record_.each_entry{ |entry_| @classifier.entry(entry_) }
        true
      end

      def extra_entry(entry_)
        @classifier.entry(entry_)
        true
      end

      def finish
        @formatter.finish
      end

    end


  end

end
