# -----------------------------------------------------------------------------
# 
# Sawmill formatter utility
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
  
  class Rotater
    
    
    # A rotation strategy that "shifts" log files by appending index numbers
    # to the filename when the file reaches a certain size or age. So when
    # the file "foo.log" is ready to rotate, it is renamed "foo.log.0", and
    # a new "foo.log" is started. When that one is ready to rotate, the
    # oldest "foo.log.0" is shifted down to "foo.log.1", "foo.log" is
    # renamed to "foo.log.0", and a new "foo.log" is started. So the oldest
    # logfile is always the one with the largest number suffix, and the
    # file currently being written to has no suffix.
    # This is a common rotation strategy for many unix tools.
    
    class ShiftingLogFile
      
      
      # Create a new shifting log file rotation strategy.
      # 
      # Recognized options include:
      # 
      # [<tt>:basedir</tt>]
      #   The base directory used if the filepath is a relative path.
      #   If not specified, the current working directory is used.
      # [<tt>:file_path</tt>]
      #   The path to the log file. This may be an absolute path or a
      #   path relative to basedir.
      #   If not specified, defaults to "sawmill.log".
      # [<tt>:max_file_size</tt>]
      #   A logfile will try to rotate once it has reached this size in
      #   bytes. If not specified, the file size is not checked.
      # [<tt>:shift_period</tt>]
      #   A logfile will try to rotate once it has been in service for
      #   this many seconds. This parameter also recognizes the values
      #   <tt>:yearly</tt>, <tt>:monthly</tt>, <tt>:daily</tt>, 
      #   and <tt>:hourly</tt>. If not specified, the file's age is
      #   not checked.
      # [<tt>:history_size</tt>]
      #   The maximum number of old logfiles (files with indexes) to
      #   keep. Files beyond this history size will be automatically
      #   deleted. Default is 1. This value must be at least 1.
      
      def initialize(options_)
        @max_logfile_size = options_[:max_file_size] || options_[:max_logfile_size]
        @shift_period = options_[:shift_period]
        case @shift_period
        when :yearly
          @shift_period = 60*60*24*365
        when :monthly
          @shift_period = 60*60*24*30
        when :daily
          @shift_period = 60*60*24
        when :hourly
          @shift_period = 60*60
        end
        @history_size = options_[:history_size].to_i
        @history_size = 1 if @history_size < 1 && (@max_logfile_size || @shift_period)
        @normal_path = ::File.expand_path(options_[:file_path] || options_[:filepath] || 'sawmill.log', 
                                          options_[:basedir] || ::Dir.getwd)
        @preferred_handle = 0
        @open_handles = {}
        @last_shift = ::Time.now
      end
      
      
      # Implements the rotation strategy contract.
      
      def preferred_handle
        @preferred_handle
      end
      
      
      # Implements the rotation strategy contract.
      
      def open_handle(handle_)
        if handle_ == @preferred_handle
          path_ = @normal_path
        else
          path_ = "#{@normal_path}.#{@preferred_handle-handle_-1}"
        end
        file_ = ::File.open(path_, 'a')
        file_.sync = true
        @open_handles[handle_] = true
        file_
      end
      
      
      # Implements the rotation strategy contract.
      
      def close_handle(handle_, io_)
        io_.close
        if @preferred_handle - handle_ > @history_size
          ::File.delete("#{@normal_path}.#{@preferred_handle-handle_-1}") rescue nil
        end
        @open_handles.delete(handle_)
        nil
      end
      
      
      # Implements the rotation strategy contract.
      
      def before_write
        return unless @max_logfile_size || @shift_period
        turnover_ = false
        if @max_logfile_size && ::File.file?(@normal_path) && ::File.size(@normal_path) > @max_logfile_size
          turnover_ = true
        end
        if @shift_period && (::Time.now - @last_shift) > @shift_period
          turnover_ = true
        end
        if turnover_
          max_ = @preferred_handle - @open_handles.keys.min + 1
          max_ = @history_size if max_ < @history_size
          ::File.delete("#{@normal_path}.#{max_-1}") rescue nil
          (max_-1).downto(1) do |index_|
            ::File.rename("#{@normal_path}.#{index_-1}", "#{@normal_path}.#{index_}") rescue nil
          end
          ::File.rename("#{@normal_path}", "#{@normal_path}.0") rescue nil
          @preferred_handle += 1
          @last_shift = ::Time.now
        end
      end
      
      
    end
    
    
  end
  
end
