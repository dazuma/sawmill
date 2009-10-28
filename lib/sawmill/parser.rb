# -----------------------------------------------------------------------------
# 
# Sawmill stream parser utility
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
  
  
  # A logfile parser that parses log entries from a logfile and sends them
  # to an entry processor.
  
  class Parser
    
    # :stopdoc:
    LINE_REGEXP = /^\[\s*([[:graph:]]+)\s+(\d{4})-(\d{2})-(\d{2})(T|\s)(\d{2}):(\d{2}):(\d{2})(.(\d{1,6}))?Z?\s?([+-]\d{4})?\s+([[:graph:]]+)(\s+([[:graph:]]+))?\s+([\^$.=])\]\s(.*)$/
    DIRECTIVE_REGEXP = /^#\s+sawmill_format:\s+(\w+)=(.*)$/
    ATTRIBUTE_REGEXP = /^([[:graph:]]+)\s([=+\/-])\s/
    # :startdoc:
    
    
    # Create a new parser that reads from the given stream.
    # 
    # You should provide a processor to receive the data from the logfile.
    # The processor may be either an entry processor or a record processor.
    # You may also pass nil for the processor. In this case, the generated
    # log entries will not be sent to a processor but will still be returned
    # by the parse_one_entry method.
    # 
    # Recognized options include:
    # 
    # <tt>:levels</tt>
    #   Sawmill::LevelGroup to use to parse log levels.
    #   If not specified, Sawmill::STANDARD_LEVELS is used by default.
    # <tt>:emit_incomplete_records_at_eof</tt>
    #   If set to true, causes any incomplete log records to be emitted
    #   in their incomplete state when EOF is reached.
    
    def initialize(io_, processor_, opts_={})
      @io = io_
      @processor = nil
      if processor_.respond_to?(:record) && processor_.respond_to?(:extra_entry)
        @processor = RecordBuilder.new(processor_)
      elsif processor_.respond_to?(:begin_record) && processor_.respond_to?(:end_record)
        @processor = processor_
      end
      @levels = opts_[:levels] || STANDARD_LEVELS
      @emit_incomplete_records_at_eof = opts_[:emit_incomplete_records_at_eof]
      @current_record_id = nil
      @parser_directives = {}
    end
    
    
    # Parse one log entry from the stream and emit it to the processor.
    # Also returns the log entry.
    # Returns nil if EOF has been reached.
    
    def parse_one_entry
      str_ = @io.gets
      entry_ = nil
      if str_
        match_ = LINE_REGEXP.match(str_)
        if match_
          level_ = @levels.get(match_[1])
          timestamp_ = ::Time.utc(match_[2].to_i, match_[3].to_i, match_[4].to_i,
            match_[6].to_i, match_[7].to_i, match_[8].to_i, match_[10].to_s.ljust(6, '0').to_i)
          offset_ = match_[11].to_i
          if offset_ != 0
            neg_ = offset_ < 0
            offset_ = -offset_ if neg_
            secs_ = offset_ / 100 * 3600 + offset_ % 100 * 60
            if neg_
              timestamp_ += secs_
            else
              timestamp_ -= secs_
            end
          end
          progname_ = match_[12]
          record_id_ = match_[14] || @current_record_id
          type_code_ = match_[15]
          str_ = match_[16]
          if str_ =~ /(\\+)$/
            count_ = $1.length
            str_ = $` + "\\"*(count_/2)
            while count_ % 2 == 1
              str2_ = @io.gets
              if str2_ && str2_ =~ /(\\*)\n?$/
                count_ = $1.length
                str_ << "\n" << $` << "\\"*(count_/2)
              else
                break
              end
            end
          end
          case type_code_
          when '^'
            if str_ =~ /^BEGIN\s/
              @current_record_id = $'
              entry_ = Entry::BeginRecord.new(level_, timestamp_, progname_, @current_record_id)
              @processor.begin_record(entry_) if @processor
            end
          when '$'
            if str_ =~ /^END\s/
              @current_record_id = $'
              entry_ = Entry::EndRecord.new(level_, timestamp_, progname_, @current_record_id)
              @current_record_id = nil
              @processor.end_record(entry_) if @processor
            end
          when '='
            if str_ =~ ATTRIBUTE_REGEXP
              key_ = $1
              opcode_ = $2
              value_ = $'
              operation_ = opcode_ == '+' ? :append : :set
              entry_ = Entry::Attribute.new(level_, timestamp_, progname_, record_id_, key_, value_, operation_)
              @processor.attribute(entry_) if @processor
            end
          end
          unless entry_
            entry_ = Entry::Message.new(level_, timestamp_, progname_, record_id_, str_)
            @processor.message(entry_) if @processor
          end
        else
          if str_ =~ DIRECTIVE_REGEXP
            @parser_directives[$1] = $2
          end
          entry_ = Entry::UnknownData.new(str_.chomp)
          @processor.unknown_data(entry_) if @processor.respond_to?(:unknown_data)
        end
      else
        if @emit_incomplete_records_at_eof && @processor.respond_to?(:emit_incomplete_records)
          @processor.emit_incomplete_records
        end
      end
      entry_
    end
    
    
    # Parse the rest of the stream until EOF is reached, and emit the log
    # entries to the processor.
    
    def parse_all
      while parse_one_entry; end
    end
    
    
  end
  
  
end
