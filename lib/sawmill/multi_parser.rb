# -----------------------------------------------------------------------------
# 
# Sawmill multi-stream parser utility
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
  
  
  # A logfile parser that parses log entries from multiple logfile streams,
  # sorts by timestamp, and sends them to a processor.
  
  class MultiParser
    
    
    # Create a new parser that reads from the given streams.
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
    #   in their incomplete state when EOF is reached on all streams.
    
    def initialize(io_array_, processor_, opts_={})
      @emit_incomplete_records_at_eof = opts_.delete(:emit_incomplete_records_at_eof)
      @heap = Util::Heap.new{ |a_, b_| a_[1].timestamp <=> b_[1].timestamp }
      @queue = Util::Queue.new
      encoding_array_ = opts_.delete(:encoding_array)
      internal_encoding_array_ = opts_.delete(:internal_encoding_array)
      io_array_.each_with_index do |io_, index_|
        opts2_ = opts_.dup
        opts2_[:encoding] = encoding_array_[index_] if encoding_array_
        opts2_[:internal_encoding] = internal_encoding_array_[index_] if internal_encoding_array_
        _enqueue(Parser.new(io_, nil, opts2_))
      end
      @processor = nil
      if processor_.respond_to?(:record) && processor_.respond_to?(:extra_entry)
        @processor = RecordBuilder.new(processor_)
      elsif processor_.respond_to?(:begin_record) && processor_.respond_to?(:end_record)
        @processor = processor_
      end
      @classifier = @processor ? EntryClassifier.new(@processor) : nil
    end
    
    
    # Parse one log entry from the streams and emit it to the processor.
    # Also returns the log entry.
    # Returns nil if EOF has been reached on all streams.
    
    def parse_one_entry
      entry_ = @queue.dequeue
      unless entry_
        data_ = @heap.remove
        if data_
          _enqueue(data_[0])
          entry_ = data_[1]
        else
          if @emit_incomplete_records_at_eof && @processor.respond_to?(:emit_incomplete_records)
            @processor.emit_incomplete_records
          end
        end
      end
      @classifier.entry(entry_) if entry_
      entry_
    end
    
    
    # Parse until EOF is reached on all streams, and emit the log
    # entries to the processor.
    
    def parse_all
      while parse_one_entry; end
    end
    
    
    private
    
    def _enqueue(parser_)  # :nodoc:
      loop do
        entry_ = parser_.parse_one_entry
        return unless entry_
        if entry_.type == :unknown_data
          @queue.enqueue(entry_)
        else
          @heap << [parser_, entry_]
          return
        end
      end
    end
    
    
  end
  
  
end
