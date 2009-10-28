# -----------------------------------------------------------------------------
# 
# Sawmill log record class
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
  
  
  # A log record.
  # 
  # Log records are sequences of related log entries with a common record
  # ID, beginning with a begin_record and ending with an end_record. Log
  # records therefore can be analyzed as a group, for example to measure the
  # time taken by an aggregate action such as a website request.
  # 
  # Log records must follow a particular protocol:
  #
  # * The first entry must be begin_record.
  # * The last entry must be end_record.
  # * No other begin_record or end_record entries may be present.
  # * All entries must have the same non-nil record_id.
  # * Entries must be in nondecreasing order of timestamp.
  # 
  # The only exception to these rules are incomplete log records, in which
  # the final end_record is not present.
  
  class Record
    
    
    # Create a log record.
    # 
    # You may optionally pass in an array of log entries to populate the
    # record either partially or completely. If you do, note that
    # Errors::IllegalRecordError may be raised if the log entries do not
    # follow the log record protocol-- e.g. if the first entry is not a
    # begin_record, etc.
    
    def initialize(entries_=nil)
      @started = false
      @complete = false
      @message_count = 0
      @entries = []
      @attributes = {}
      if entries_ && entries_.size > 0
        entries_.each do |entry_|
          add_entry(entry_)
        end
      end
    end
    
    
    def to_s  # :nodoc:
      "#{type}: #{@line}"
    end
    
    def inspect  # :nodoc:
      "#<#{self.class}:0x#{object_id.to_s(16)} record_id=#{record_id.inspect}>"
    end
    
    
    # Append a log entry to this record.
    # 
    # Entries must be added in order. Raises Errors::IllegalRecordError if
    # the log record protocol is violated
    
    def add_entry(entry_)
      empty_ = @entries.size == 0
      if entry_.type == :unknown_data
        raise Errors::IllegalRecordError, "You cannot add an unknown_data entry to a record"
      end
      if empty_ && entry_.type != :begin_record
        raise Errors::IllegalRecordError, "First entry in a record must be a begin_record"
      elsif !empty_ && entry_.type == :begin_record
        raise Errors::IllegalRecordError, "Extra begin_record found"
      end
      if @complete
        raise Errors::IllegalRecordError, "Cannot have entries after end_record"
      end
      if empty_
        if entry_.record_id.nil?
          raise Errors::IllegalRecordError, "Entry has no record_id"
        end
      else
        last_ = @entries.last
        if last_.record_id != entry_.record_id
          raise Errors::IllegalRecordError, "Entry has a mismatching record_id"
        end
        if last_.timestamp > entry_.timestamp
          raise Errors::IllegalRecordError, "Entry's timestamp is earlier than the previous entry"
        end
      end
      case entry_.type
      when :begin_record
        @started = true
      when :end_record
        @complete = true
      when :attribute
        case entry_.operation
        when :set
          @attributes[entry_.key] = entry_.value
        when :append
          val_ = @attributes[entry_.key]
          case val_
          when Array
            val_ << entry_.value
          when String
            @attributes[entry_.key] = [val_, entry_.value]
          when nil
            @attributes[entry_.key] = [entry_.value]
          end
        end
      when :message
        @message_count += 1
      end
      @entries << entry_
    end
    
    
    # Returns true if the initial begin_record has been added.
    
    def started?
      @started
    end
    
    
    # Returns true if the final end_record has been added.
    
    def complete?
      @complete
    end
    
    
    # Returns the record ID as a string.
    
    def record_id
      @entries.size > 0 ? @entries.first.record_id : nil
    end
    
    
    # Returns the beginning timestamp as a Time object, if the log record
    # has been started, or nil otherwise.
    
    def begin_timestamp
      @started ? @entries.first.timestamp : nil
    end
    
    
    # Returns the ending timestamp as a Time object, if the log record
    # has been completed, or nil otherwise.
    
    def end_timestamp
      @complete ? @entries.last.timestamp : nil
    end
    
    
    # Returns the number of log entries currently in this record.
    
    def entry_count
      @entries.size
    end
    
    alias_method :size, :entry_count
    
    
    # Returns the number of message entries currently in this record.
    
    def message_count
      @message_count
    end
    
    
    # Iterate over all log entries, passing each to the given block.
    
    def each_entry(&block_)
      @entries.each(&block_)
    end
    
    
    # Iterate over all log message entries, passing each to the given block.
    
    def each_message
      @entries.each do |entry_|
        if entry_.type == :message
          yield entry_
        end
      end
    end
    
    
    # Returns an array of all log entries.
    
    def all_entries
      @entries.dup
    end
    
    
    # Returns an array of all log message entries.
    
    def all_messages
      @entries.find_all{ |entry_| entry_.type == :message }
    end
    
    
    # Get the value of the given attribute.
    # Returns a string if the attribute has a single value.
    # Returns an array of strings if the attribute has multiple values.
    # Returns nil if the attribute is not set.
    
    def attribute(key_)
      @attributes[key_.to_s]
    end
    
    
    # Get an array of attribute keys present in this log record.
    
    def attribute_keys
      @attributes.keys
    end
    
    
  end
  
  
end
