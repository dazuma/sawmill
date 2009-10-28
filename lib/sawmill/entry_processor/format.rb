# -----------------------------------------------------------------------------
# 
# Sawmill entry processor that formats for log files
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
    
    
    # This processor formats log entries and writes them to a destination.
    
    class Format < Base
      
      
      # Create a formatter.
      # 
      # The destination can be a ruby IO object, a Sawmill::Rotater, or any
      # object that responds to the "write" and "close" methods as defined
      # by the ruby IO class.
      # 
      # Recognized options include:
      # 
      # <tt>:include_id</tt>::
      #   Include the record ID in every log entry. Default is false.
      # <tt>:fractional_second_digits</tt>::
      #   Number of digits of fractional seconds to display in timestamps.
      #   Default is 2. Accepted values are 0 to 6.
      # <tt>:level_width</tt>::
      #   Column width of the level field.
      # <tt>:local_time</tt>::
      #   If true, outputs local time with the timezone offset indicator.
      #   If false (the default), outputs UTC.
      # <tt>:iso_8601_time</tt>::
      #   If true, outputs time in strict ISO 8601 format.
      #   If false (the default), outputs a slightly more readable format.
      
      def initialize(destination_, opts_={})
        if destination_.kind_of?(Rotater)
          @rotater = destination_
          @channels = {}
          @standby_channel = nil
        elsif destination_.respond_to?(:close) && destination_.respond_to?(:write)
          @io = destination_
        else
          raise ArgumentError, "Unknown destination type"
        end
        @include_id = opts_[:include_id]
        @fractional_second_digits = (opts_[:fractional_second_digits] || 2).to_i
        @fractional_second_digits = 0 if @fractional_second_digits < 0
        @fractional_second_digits = 6 if @fractional_second_digits > 6
        @usec_factor = 1
        (6 - @fractional_second_digits).times{ @usec_factor *= 10 }
        @level_width = opts_[:level_width]
      end
      
      
      def begin_record(entry_)
        return false unless @io || @rotater
        record_id_ = entry_.record_id
        if @rotater
          if @standby_channel
            io_ = @standby_channel
            @standby_channel = nil
          else
            io_ = @rotater.create_channel
          end
          @channels[record_id_] = io_
        else
          io_ = @io
        end
        io_.write(_format_entry(entry_, '^', "BEGIN #{record_id_}"))
        true
      end
      
      def end_record(entry_)
        return false unless @io || @rotater
        record_id_ = entry_.record_id
        str_ = _format_entry(entry_, '$', "END #{record_id_}")
        if @rotater
          if (channel_ = @channels.delete(record_id_))
            @standby_channel.close if @standby_channel
            @standby_channel = channel_
          else
            @standby_channel ||= @rotater.create_channel
          end
          @standby_channel.write(str_)
          @standby_channel.check_rotate
        else
          @io.write(str_)
        end
        true
      end
      
      def message(entry_)
        return false unless @io || @rotater
        _write_str(_format_entry(entry_, '.', entry_.message), entry_.record_id)
        true
      end
      
      def attribute(entry_)
        return false unless @io || @rotater
        opcode_ = entry_.operation == :append ? '+' : '='
        str_ = _format_entry(entry_, '=', "#{entry_.key} #{opcode_} #{entry_.value}")
        _write_str(str_, entry_.record_id)
        true
      end
      
      def unknown_data(entry_)
        return false unless @io || @rotater
        _write_str(entry_.line+"\n", nil)
        true
      end
      
      def close
        if @rotater
          @default_channel.close
          @channels.values.each{ |channel_| channel_.close }
          @rotater = nil
        elsif @io
          @io.close
          @io = nil
        end
      end
      
      private
      
      def _write_str(str_, record_id_)  # :nodoc:
        if @rotater
          io_ = @channels[record_id_]
          if io_
            io_.write(str_)
          else
            @standby_channel ||= @rotater.create_channel
            @standby_channel.write(str_)
            @standby_channel.check_rotate
          end
        else
          @io.write(str_)
        end
      end
      
      def _format_entry(entry_, marker_, str_)  # :nodoc:
        id_ = @include_id ? entry_.record_id : nil
        id_ = id_ ? ' '+id_ : ''
        time_ = entry_.timestamp.getutc
        str_ = str_.split("\n", -1).map do |line_|
          if line_ =~ /(\\+)$/
            "#{$`}#{$1}#{$1}"
          else
            line_
          end
        end.join("\\\n")
        time_ = entry_.timestamp
        if @local_time
          time_ = time_.getlocal
        else
          time_ = time_.getutc
        end
        if @iso_8601_time
          timestr_ = time_.strftime('%Y-%m-%dT%H:%M:%S')
        else
          timestr_ = time_.strftime('%Y-%m-%d %H:%M:%S')
        end
        if @fractional_second_digits > 0
          timestr_ << (".%0#{@fractional_second_digits}d" % (time_.usec / @usec_factor))
        end
        if @local_time
          offset_ = time_.utc_offset
          neg_ = offset_ < 0
          offset_ = -offset_ if neg_
          offsetstr_ = "%s%02d%02d" % [(neg_ ? '-' : '+'), offset_ / 3600, (offset_ % 3600) / 60]
          if @iso_8601_time
            timestr_ << offsetstr_
          else
            timestr_ << ' ' << offsetstr_
          end
        elsif @iso_8601_time
          timestr_ << 'Z'
        end
        levelstr_ = entry_.level.name.to_s
        levelstr_ = levelstr_.rjust(@level_width) if @level_width
        "[#{levelstr_} #{timestr_} #{entry_.progname}#{id_} #{marker_}] #{str_}\n"
      end
      
    end
    
    
  end
  
  
  # Sawmill::Formatter is an alternate name for
  # Sawmill::EntryProcessor::Format
  Formatter = EntryProcessor::Format
  
  
end
