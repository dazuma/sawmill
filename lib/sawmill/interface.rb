# -----------------------------------------------------------------------------
# 
# Sawmill convenience interface
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


# This module is a namespace for Sawmill.
# 
# It also contains some convenience class methods.

module Sawmill
  
  class << self
    
    
    # Creates a new logger that writes to a single logfile.
    # You may provide either the path to the logfile, or an IO object to
    # write to, such as STDOUT.
    # 
    # You may pass the same options taken by Sawmill::Logger#new and
    # Sawmill::EntryProcessor::Format#new, which are:
    # 
    # <tt>:levels</tt>::
    #   Use a custom Sawmill::LevelGroup. Normally, you should leave this
    #   set to the default, which is Sawmill::STANDARD_LEVELS.
    # <tt>:level</tt>::
    #   Default level to use for log messages when no level is explicitly
    #   provided. By default, this is set to the level group's default,
    #   which in the case of the standard levels is :INFO.
    # <tt>:attribute_level</tt>::
    #   Default level to use for attributes when no level is explicitly
    #   provided. By default, this is set to the level group's highest,
    #   level, which in the case of the standard levels is :ANY.
    # <tt>:progname</tt>::
    #   Progname to use in log messages. Default is "sawmill".
    # <tt>:record_progname</tt>::
    #   Progname to use in special log entries dealing with log records
    #   (i.e. record delimiters and attribute messages). Default is the
    #   same as the normal progname setting.
    # <tt>:record_id_generator</tt>::
    #   A proc that generates and returns a new record ID if one is not
    #   explicitly passed into begin_record. If you do not provide a
    #   generator, the default one is used, which generates an ID using the
    #   variant 4 (random) UUID standard.
    # <tt>:include_id</tt>::
    #   Write the record ID in every log entry. Default is false.
    # <tt>:fractional_second_digits</tt>::
    #   Number of digits of fractional seconds to write in timestamps.
    #   Default is 2. Accepted values are 0 to 6.
    # <tt>:level_width</tt>::
    #   Column width of the level field.
    # <tt>:local_time</tt>::
    #   If true, outputs local time with the timezone offset indicator.
    #   If false (the default), outputs UTC.
    # <tt>:iso_8601_time</tt>::
    #   If true, outputs time in strict ISO 8601 format.
    #   If false (the default), outputs a slightly more readable format.
    
    def simple_logger(filepath_=::STDOUT, opts_={})
      if filepath_.kind_of?(::String)
        io_ = ::File.open(filepath_)
      elsif filepath_.respond_to?(:write) && filepath_.respond_to?(:close)
        io_ = filepath_
      else
        raise ::ArgumentError, "You must pass a file path or an IO object"
      end
      processor_ = EntryProcessor::Format.new(io_, opts_)
      Logger.new(opts_.merge(:processor => processor_))
    end
    
    
    # Creates a new logger that writes to a logfile that rotates
    # automatically by "shifting". This is a standard rotation strategy
    # used by many unix tools.
    # 
    # You must provide the logfile path, a shifting period, and a maximum
    # file size.
    # 
    # The period specifies how often to rotate the logfile. Possible values
    # include <tt>:yearly</tt>, <tt>:monthly</tt>, <tt>:daily</tt>, and
    # <tt>:hourly</tt>. You may also specify an integer value, which is
    # interpreted as a number of seconds. Finally, you may pass nil to
    # disable checking of the file's age. If you do pass nil, you should
    # provide a maximum size.
    # 
    # The maximum size is the maximum file size in bytes. You may provide
    # a number, or nil to disable checking of the file size.
    # 
    # You may pass the same options taken by Sawmill::Logger#new,
    # Sawmill::EntryProcessor::Format#new, Sawmill::Rotater#new, and
    # Sawmill::Rotater::ShiftingLogFile#new, which are:
    # 
    # <tt>:levels</tt>::
    #   Use a custom Sawmill::LevelGroup. Normally, you should leave this
    #   set to the default, which is Sawmill::STANDARD_LEVELS.
    # <tt>:level</tt>::
    #   Default level to use for log messages when no level is explicitly
    #   provided. By default, this is set to the level group's default,
    #   which in the case of the standard levels is :INFO.
    # <tt>:attribute_level</tt>::
    #   Default level to use for attributes when no level is explicitly
    #   provided. By default, this is set to the level group's highest,
    #   level, which in the case of the standard levels is :ANY.
    # <tt>:progname</tt>::
    #   Progname to use in log messages. Default is "sawmill".
    # <tt>:record_progname</tt>::
    #   Progname to use in special log entries dealing with log records
    #   (i.e. record delimiters and attribute messages). Default is the
    #   same as the normal progname setting.
    # <tt>:record_id_generator</tt>::
    #   A proc that generates and returns a new record ID if one is not
    #   explicitly passed into begin_record. If you do not provide a
    #   generator, the default one is used, which generates an ID using the
    #   variant 4 (random) UUID standard.
    # <tt>:include_id</tt>::
    #   Write the record ID in every log entry. Default is false.
    # <tt>:fractional_second_digits</tt>::
    #   Number of digits of fractional seconds to write in timestamps.
    #   Default is 2. Accepted values are 0 to 6.
    # <tt>:level_width</tt>::
    #   Column width of the level field.
    # <tt>:local_time</tt>::
    #   If true, outputs local time with the timezone offset indicator.
    #   If false (the default), outputs UTC.
    # <tt>:iso_8601_time</tt>::
    #   If true, outputs time in strict ISO 8601 format.
    #   If false (the default), outputs a slightly more readable format.
    # <tt>:omit_directives</tt>::
    #   If true, omit standard logfile directives. Default is false.
    # <tt>:basedir</tt>::
    #   The base directory used if the filepath is a relative path.
    #   If not specified, the current working directory is used.
    # <tt>:history_size</tt>::
    #   The maximum number of old logfiles (files with indexes) to
    #   keep. Files beyond this history size will be automatically
    #   deleted. Default is 1. This value must be at least 1.
    # <tt>:encoding</tt>::
    #   Specify an encoding name for file data. (Ruby 1.9 only)
    #   If not specified, uses the default external encoding.
    
    def shifting_logfile(filepath_, period_, max_size_, opts_={})
      rotater_ = Rotater.new(Rotater::ShiftingLogFile, opts_.merge(:file_path => filepath_,
        :max_file_size => max_size_, :shift_period => period_))
      processor_ = EntryProcessor::Format.new(rotater_, opts_)
      Logger.new(opts_.merge(:processor => processor_))
    end
    
    
    # Creates a new logger that writes to a logfile that rotates
    # automatically by tagging filenames with a datestamp.
    # 
    # You must provide the file path prefix, and a turnover frequency.
    # Possible values for the turnover frequency are <tt>:yearly</tt>,
    # <tt>:monthly</tt>, <tt>:daily</tt>, <tt>:hourly</tt>, and
    # <tt>:never</tt>.
    # 
    # You may pass the same options taken by Sawmill::Logger#new,
    # Sawmill::EntryProcessor::Format#new, Sawmill::Rotater#new, and
    # Sawmill::Rotater::DateBasedLogFile#new, which are:
    # 
    # <tt>:levels</tt>::
    #   Use a custom Sawmill::LevelGroup. Normally, you should leave this
    #   set to the default, which is Sawmill::STANDARD_LEVELS.
    # <tt>:level</tt>::
    #   Default level to use for log messages when no level is explicitly
    #   provided. By default, this is set to the level group's default,
    #   which in the case of the standard levels is :INFO.
    # <tt>:attribute_level</tt>::
    #   Default level to use for attributes when no level is explicitly
    #   provided. By default, this is set to the level group's highest,
    #   level, which in the case of the standard levels is :ANY.
    # <tt>:progname</tt>::
    #   Progname to use in log messages. Default is "sawmill".
    # <tt>:record_progname</tt>::
    #   Progname to use in special log entries dealing with log records
    #   (i.e. record delimiters and attribute messages). Default is the
    #   same as the normal progname setting.
    # <tt>:record_id_generator</tt>::
    #   A proc that generates and returns a new record ID if one is not
    #   explicitly passed into begin_record. If you do not provide a
    #   generator, the default one is used, which generates an ID using the
    #   variant 4 (random) UUID standard.
    # <tt>:include_id</tt>::
    #   Write the record ID in every log entry. Default is false.
    # <tt>:fractional_second_digits</tt>::
    #   Number of digits of fractional seconds to write in timestamps.
    #   Default is 2. Accepted values are 0 to 6.
    # <tt>:level_width</tt>::
    #   Column width of the level field.
    # <tt>:local_time</tt>::
    #   If true, outputs local time with the timezone offset indicator.
    #   If false (the default), outputs UTC.
    # <tt>:iso_8601_time</tt>::
    #   If true, outputs time in strict ISO 8601 format.
    #   If false (the default), outputs a slightly more readable format.
    # <tt>:omit_directives</tt>::
    #   If true, omit standard logfile directives. Default is false.
    # <tt>:basedir</tt>::
    #   The base directory used if the filepath is a relative path.
    #   If not specified, the current working directory is used.
    # <tt>:name_suffix</tt>::
    #   The logfile name suffix.
    #   In the filename "rails.2009-10-11.log", the suffix is ".log".
    #   If not specified, defaults to ".log".
    # <tt>:local_datestamps</tt>::
    #   If true, use the local timezone to create datestamps.
    #   The default is to use UTC.
    # <tt>:encoding</tt>::
    #   Specify an encoding name for file data. (Ruby 1.9 only)
    #   If not specified, uses the default external encoding.
    
    def date_based_logfile(filepath_, frequency_, opts_={})
      rotater_ = Rotater.new(Rotater::DateBasedLogFile, opts_.merge(:path_prefix => filepath_,
        :turnover_frequency => frequency_))
      processor_ = EntryProcessor::Format.new(rotater_, opts_)
      Logger.new(opts_.merge(:processor => processor_))
    end
    
    
    # Open one or more log files and run them through an entry processor.
    # The processor is built on the fly using the EntryProcessor DSL.
    # See EntryProcessor#build for more details.
    # 
    # You may pass the same options taken by Sawmill::MultiParser#new,
    # which are:
    # 
    # <tt>:levels</tt>::
    #   Sawmill::LevelGroup to use to parse log levels.
    #   If not specified, Sawmill::STANDARD_LEVELS is used by default.
    # <tt>:emit_incomplete_records_at_eof</tt>::
    #   If set to true, causes any incomplete log records to be emitted
    #   in their incomplete state when EOF is reached on all streams.
    # 
    # Additionally, these options are recognized:
    # 
    # <tt>:encoding</tt>::
    #   Specify an encoding for file data. (Ruby 1.9 only.)
    #   You may specify an encoding name or an encoding object.
    #   If not specified, uses the default external encoding.
    # <tt>:internal_encoding</tt>::
    #   Specify an encoding to transcode to. (Ruby 1.9 only.)
    #   You may specify an encoding name or an encoding object.
    #   If not specified, uses the default internal encoding.
    
    def open_entries(globs_, opts_={}, &block_)
      processor_ = EntryProcessor.build(&block_)
      open_files(globs_, processor_, opts_.merge(:finish => true))
    end
    
    
    # Open one or more log files and run them through a record processor.
    # The processor is built on the fly using the RecordProcessor DSL.
    # See RecordProcessor#build for more details.
    # 
    # You may pass the same options taken by Sawmill::MultiParser#new,
    # which are:
    # 
    # <tt>:levels</tt>::
    #   Sawmill::LevelGroup to use to parse log levels.
    #   If not specified, Sawmill::STANDARD_LEVELS is used by default.
    # <tt>:emit_incomplete_records_at_eof</tt>::
    #   If set to true, causes any incomplete log records to be emitted
    #   in their incomplete state when EOF is reached on all streams.
    # 
    # Additionally, these options are recognized:
    # 
    # <tt>:encoding</tt>::
    #   Specify an encoding for file data. (Ruby 1.9 only.)
    #   You may specify an encoding name or an encoding object.
    #   If not specified, uses the default external encoding.
    # <tt>:internal_encoding</tt>::
    #   Specify an encoding to transcode to. (Ruby 1.9 only.)
    #   You may specify an encoding name or an encoding object.
    #   If not specified, uses the default internal encoding.
    
    def open_records(globs_, opts_={}, &block_)
      processor_ = RecordProcessor.build(&block_)
      open_files(globs_, processor_, opts_.merge(:finish => true))
    end
    
    
    # Open one or more log files and run them through the given
    # EntryProcessor or RecordProcessor.
    # 
    # You may pass the same options taken by Sawmill::MultiParser#new,
    # which are:
    # 
    # <tt>:levels</tt>::
    #   Sawmill::LevelGroup to use to parse log levels.
    #   If not specified, Sawmill::STANDARD_LEVELS is used by default.
    # <tt>:emit_incomplete_records_at_eof</tt>::
    #   If set to true, causes any incomplete log records to be emitted
    #   in their incomplete state when EOF is reached on all streams.
    # 
    # Additionally, these options are recognized:
    # 
    # <tt>:finish</tt>::
    #   If set to true, the "finish" method is called on the processor
    #   after all files have been parsed, and the return value is returned.
    #   Otherwise, the processor is left open and nil is returned.
    # <tt>:encoding</tt>::
    #   Specify an encoding for file data. (Ruby 1.9 only.)
    #   You may specify an encoding name or an encoding object.
    #   If not specified, uses the default external encoding.
    # <tt>:internal_encoding</tt>::
    #   Specify an encoding to transcode to. (Ruby 1.9 only.)
    #   You may specify an encoding name or an encoding object.
    #   If not specified, uses the default internal encoding.
    
    def open_files(globs_, processor_, opts_={})
      finish_opt_ = opts_.delete(:finish)
      encoding_ = opts_.delete(:encoding)
      internal_encoding_ = opts_.delete(:internal_encoding)
      mode_ = 'r'
      if defined?(::Encoding)
        if encoding_
          encoding_ = ::Encoding.find(encoding_) unless encoding_.respond_to?(:name)
          encoding_ = nil if encoding_ == ::Encoding.default_external
        end
        if internal_encoding_
          internal_encoding_ = ::Encoding.find(internal_encoding_) unless internal_encoding_.respond_to?(:name)
          internal_encoding_ = nil if internal_encoding_ == ::Encoding.default_internal
        end
        if encoding_
          mode_ << ":#{encoding_.name}"
        elsif internal_encoding_
          mode_ << ":#{::Encoding.default_external.name}"
        end
        mode_ << ":#{internal_encoding_.name}" if internal_encoding_
      else
        encoding_ = nil
        internal_encoding_ = nil
      end
      globs_ = [globs_] unless globs_.kind_of?(::Array)
      io_array_ = []
      encoding_array_ = []
      internal_encoding_array_ = []
      begin
        globs_.each do |glob_|
          ::Dir.glob(glob_).each do |path_|
            if path_ =~ /\.gz$/
              io_ = ::File.open(path_, 'rb')
              io_array_ << ::Zlib::GzipReader.new(io_)
              encoding_array_ << encoding_
              internal_encoding_array_ << internal_encoding_
            else
              io_array_ << ::File.open(path_, mode_)
              encoding_array_ << nil
              internal_encoding_array_ << nil
            end
          end
        end
        opts_[:encoding_array] = encoding_array_ if encoding_array_.find{ |elem_| elem_ }
        opts_[:internal_encoding_array] = internal_encoding_array_ if internal_encoding_array_.find{ |elem_| elem_ }
        MultiParser.new(io_array_, processor_, opts_).parse_all
      ensure
        io_array_.each do |io_|
          io_.close rescue nil
        end
      end
      finish_opt_ ? processor_.finish : nil
    end
    
    
  end
  
end
