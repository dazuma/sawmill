# -----------------------------------------------------------------------------
#
# Sawmill log entry classes
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


  # This module is a namespace for log entry classes.

  module Entry


    # A log entry that doesn't conform to sawmill's format.

    class UnknownData


      def initialize(line_)
        @line = line_.to_s
      end


      # Returns <tt>:unknown_data</tt>
      def type; :unknown_data end

      # The line in the logfile as a raw string
      attr_reader :line


      def to_s  # :nodoc:
        "#{type}: #{@line}"
      end

      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} line=#{@line.inspect}>"
      end

      def eql?(obj_)  # :nodoc:
        obj_.kind_of?(Entry::UnknownData) && obj_.line == @line
      end

      def ==(obj_)  # :nodoc:
        eql?(obj_)
      end

      def hash  # :nodoc:
        type.hash ^ @line.hash
      end

    end


    # A log entry containing a standard log message.

    class Message


      def initialize(level_, timestamp_, progname_, record_id_, message_)
        @level = level_
        @timestamp = timestamp_
        @progname = progname_.to_s
        @progname.gsub!(/\s+/, '')
        @record_id = record_id_.nil? ? nil : record_id_.to_s
        @record_id.gsub!(/\s+/, '') if @record_id
        @message = message_.to_s
      end


      # Returns <tt>:message</tt>
      def type; :message; end

      # The log level as a Sawmill::Level object
      attr_reader :level

      # The timestamp as a Time object
      attr_reader :timestamp

      # The progname as a string
      attr_reader :progname

      # The record ID as a string
      attr_reader :record_id

      # The message as a string
      attr_reader :message


      def to_s  # :nodoc:
        "#{type}: #{@message}"
      end

      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} level=#{@level.name} time=#{@timestamp.to_s.inspect} progname=#{@progname.inspect} record_id=#{@record_id.inspect} message=#{@message.inspect}>"
      end

      def eql?(obj_)  # :nodoc:
        obj_.kind_of?(Entry::Message) && obj_.level == @level && obj_.timestamp == @timestamp && obj_.progname == @progname && obj_.record_id == @record_id && obj_.message == @message
      end

      def ==(obj_)  # :nodoc:
        eql?(obj_)
      end

      def hash  # :nodoc:
        type.hash ^ @level.hash ^ @timestamp.hash ^ @progname.hash ^ @record_id.hash ^ @message.hash
      end


    end


    # A log entry signalling the beginning of a log record.

    class BeginRecord


      def initialize(level_, timestamp_, progname_, record_id_)
        @level = level_
        @timestamp = timestamp_
        @progname = progname_.to_s
        @progname.gsub!(/\s+/, '')
        @record_id = record_id_.nil? ? nil : record_id_.to_s
        @record_id.gsub!(/\s+/, '') if @record_id
      end


      # Returns <tt>:begin_record</tt>
      def type; :begin_record; end

      # The log level as a Sawmill::Level object
      attr_reader :level

      # The timestamp as a Time object
      attr_reader :timestamp

      # The progname as a string
      attr_reader :progname

      # The record ID as a string
      attr_reader :record_id


      def to_s  # :nodoc:
        "#{type}: #{@record_id}"
      end

      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} level=#{@level.name} time=#{@timestamp.to_s.inspect} progname=#{@progname.inspect} record_id=#{@record_id.inspect}>"
      end

      def eql?(obj_)  # :nodoc:
        obj_.kind_of?(Entry::BeginRecord) && obj_.level == @level && obj_.timestamp == @timestamp && obj_.progname == @progname && obj_.record_id == @record_id
      end

      def ==(obj_)  # :nodoc:
        eql?(obj_)
      end

      def hash  # :nodoc:
        type.hash ^ @level.hash ^ @timestamp.hash ^ @progname.hash ^ @record_id.hash
      end


    end


    # A log entry signalling the end of a log record.

    class EndRecord


      def initialize(level_, timestamp_, progname_, record_id_)
        @level = level_
        @timestamp = timestamp_
        @progname = progname_.to_s
        @record_id = record_id_.nil? ? nil : record_id_.to_s
      end


      # Returns <tt>:end_record</tt>
      def type; :end_record; end

      # The log level as a Sawmill::Level object
      attr_reader :level

      # The timestamp as a Time object
      attr_reader :timestamp

      # The progname as a string
      attr_reader :progname

      # The record ID as a string
      attr_reader :record_id


      def to_s  # :nodoc:
        "#{type}: #{@record_id}"
      end

      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} level=#{@level.name} time=#{@timestamp.to_s.inspect} progname=#{@progname.inspect} record_id=#{@record_id.inspect}>"
      end

      def eql?(obj_)  # :nodoc:
        obj_.kind_of?(Entry::EndRecord) && obj_.level == @level && obj_.timestamp == @timestamp && obj_.progname == @progname && obj_.record_id == @record_id
      end

      def ==(obj_)  # :nodoc:
        eql?(obj_)
      end

      def hash  # :nodoc:
        type.hash ^ @level.hash ^ @timestamp.hash ^ @progname.hash ^ @record_id.hash
      end


    end


    # A log entry containing a log record attribute.

    class Attribute


      def initialize(level_, timestamp_, progname_, record_id_, key_, value_, operation_=nil)
        @level = level_
        @timestamp = timestamp_
        @progname = progname_.to_s
        @progname.gsub!(/\s+/, '')
        @record_id = record_id_.nil? ? nil : record_id_.to_s
        @record_id.gsub!(/\s+/, '') if @record_id
        @key = key_.to_s
        @key.gsub!(/\s+/, '')
        @value = value_.to_s
        @operation = operation_ || :set
      end


      # Returns <tt>:attribute</tt>
      def type; :attribute; end

      # The log level as a Sawmill::Level object
      attr_reader :level

      # The timestamp as a Time object
      attr_reader :timestamp

      # The progname as a string
      attr_reader :progname

      # The record ID as a string
      attr_reader :record_id

      # The operation, which can currently be :set or :append
      attr_reader :operation

      # The attribute key as a string
      attr_reader :key

      # The attribute value as a string
      attr_reader :value


      def to_s  # :nodoc:
        "#{type}: #{@key}=#{@value.inspect}"
      end

      def inspect  # :nodoc:
        "#<#{self.class}:0x#{object_id.to_s(16)} level=#{@level.name} time=#{@timestamp.to_s.inspect} progname=#{@progname.inspect} record_id=#{@record_id.inspect} operation=#{@operation} key=#{@key.inspect} value=#{@value.inspect}>"
      end

      def eql?(obj_)  # :nodoc:
        obj_.kind_of?(Entry::Attribute) && obj_.level == @level && obj_.timestamp == @timestamp && obj_.progname == @progname && obj_.record_id == @record_id && obj_.key == @key && obj_.value == @value && obj_.operation == @operation
      end

      def ==(obj_)  # :nodoc:
        eql?(obj_)
      end

      def hash  # :nodoc:
        type.hash ^ @level.hash ^ @timestamp.hash ^ @progname.hash ^ @record_id.hash ^ @key.hash ^ @value.hash ^ @operation.hash
      end


    end


  end


end
