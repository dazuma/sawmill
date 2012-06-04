# -----------------------------------------------------------------------------
#
# Sawmill entry processor that checks for entry field values.
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


    # A basic filter that knows how to check level and progname.
    #
    # This is a boolean processor, so it merely returns true or false based
    # on the filter result. Use this in conjunction with an If processor to
    # actually perform other actions based on the result.

    class FilterByBasicFields < Base


      # Create a new filter.
      #
      # Recognized options include:
      #
      # [<tt>:level</tt>]
      #   Lowest level that will be accepted. This should be either a
      #   Sawmill::Level object or an integer value or string/symbol that
      #   represents a level. If set to nil or not specified, this filter
      #   does not check the level.
      # [<tt>:progname</tt>]
      #   Progname filter. This can be either a string or a Regexp. If set
      #   to nil or not specified, this filter does not check the progname.
      # [<tt>:accept_record_delimiters</tt>]
      #   If set to true, accepts all begin_record and end_record entries
      #   regardless of the level or progname. If set to false, accepts no
      #   such entries. Otherwise, if not specified, those entries are
      #   subject to the usual level and progname filters.
      # [<tt>:accept_attributes</tt>]
      #   If set to true, accepts all attribute and multi_attribute entries
      #   regardless of the level or progname. If set to false, accepts no
      #   such entries. Otherwise, if not specified, those entries are
      #   subject to the usual level and progname filters.
      # [<tt>:accept_incomparable_levels</tt>]
      #   If set to true, accepts entries whose level is not comparable to
      #   the given <tt>:level</tt> setting. Otherwise, rejects all such
      #   entries.
      # [<tt>:accept_unknown</tt>]
      #   If set to true, accepts all entries of type :unknown_data.
      #   Otherwise, rejects all such entries.

      def initialize(opts_={})
        @level = opts_[:level]
        @progname = opts_[:progname]
        @accept_record_delimiters = opts_[:accept_record_delimiters]
        @accept_attributes = opts_[:accept_attributes]
        @accept_incomparable_levels = opts_[:accept_incomparable_levels]
        @accept_unknown = opts_[:accept_unknown]
      end


      def begin_record(entry_)
        @accept_record_delimiters.nil? ? _check_filter(entry_) : @accept_record_delimiters
      end

      def end_record(entry_)
        @accept_record_delimiters.nil? ? _check_filter(entry_) : @accept_record_delimiters
      end

      def message(entry_)
        _check_filter(entry_)
      end

      def attribute(entry_)
        @accept_attributes.nil? ? _check_filter(entry_) : @accept_attributes
      end

      def unknown_data(entry_)
        @accept_unknown
      end

      def finish
        nil
      end


      private


      def _check_filter(entry_)  # :nodoc:
        if @level
          level_ = entry_.level
          if @level.kind_of?(Level)
            check_level_ = @level
            if level_.group != check_level_.group
              return false unless @accept_incomparable_levels
            end
          else
            check_level_ = level_.group.get(@level)
            unless check_level_
              return false unless @accept_incomparable_levels
            end
          end
          return false if check_level_ && level_ < check_level_
        end
        return false if @progname && entry_.progname != @progname
        true
      end


    end


  end

end
