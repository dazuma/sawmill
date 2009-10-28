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
    
    
    # A rotation strategy that produces log files with the date stamp in the
    # file name. For example, you could set up an hourly log rotation that
    # produces the following files:
    # 
    #  rails.2009-10-09-22.log
    #  rails.2009-10-09-23.log
    #  rails.2009-10-10-00.log
    #  rails.2009-10-10-01.log
    #  etc...
    # 
    # The exact format depends on the rotation frequency, which could be
    # anywhere from yearly to hourly. For settings less frequent than
    # hourly, fewer fields will appear in the date stamp portion of the
    # file name.
    
    class DateBasedLogFile
      
      
      # Create a new date-based log file rotation strategy.
      # 
      # Recognized options include:
      # 
      # <tt>:turnover_frequency</tt>::
      #   How often the log files should turn over. Allowed values are:
      #   <tt>:yearly</tt>, <tt>:monthly</tt>, <tt>:daily</tt>, 
      #   <tt>:hourly</tt>, and <tt>:never</tt>.
      # <tt>:dirname</tt>::
      #   The directory for the logfiles to be output.
      #   If not specified, the current working directory is used.
      # <tt>:prefix</tt>::
      #   The logfile name prefix.
      #   In the filename "rails.2009-10-11.log", the prefix is "rails".
      #   If not specified, defaults to "sawmill".
      # <tt>:suffix</tt>::
      #   The logfile name prefix.
      #   In the filename "rails.2009-10-11.log", the suffix is ".log".
      #   If not specified, defaults to ".log".
      # <tt>:local_timezone</tt>::
      #   If true, use the local timezone to create datestamps.
      #   The default is to use UTC.
      
      def initialize(options_)
        @turnover_frequency = options_[:turnover_frequency] || :none
        dirname_ = options_[:dirname] || ::Dir.getwd
        @prefix = ::File.join(dirname_, options_[:prefix] || 'sawmill')
        @suffix = options_[:suffix] || '.log'
        @local_timezone = options_[:local_timezone]
        @date_pattern =
          case @turnover_frequency
          when :yearly then "%Y"
          when :monthly then "%Y-%m"
          when :daily then "%Y-%m-%d"
          when :hourly then "%Y-%m-%d-%H"
          else nil
          end
      end
      
      
      # Implements the rotation strategy contract.
      
      def preferred_handle
        if @date_pattern
          time_ = ::Time.now
          time_.utc unless @local_timezone
          time_.strftime(@date_pattern)
        else
          ''
        end
      end
      
      
      # Implements the rotation strategy contract.
      
      def open_handle(handle_)
        if @date_pattern
          path_ = "#{@prefix}.#{handle_}#{@suffix}"
        else
          path_ = @prefix+@suffix
        end
        file_ = ::File.open(path_, ::File::CREAT | ::File::WRONLY | ::File::APPEND)
        file_.sync = true
        file_
      end
      
      
      # Implements the rotation strategy contract.
      
      def close_handle(handle_, io_)
        io_.close
      end
      
      
      # Implements the rotation strategy contract.
      
      def before_write
      end
      
      
    end
    
    
  end
  
end
