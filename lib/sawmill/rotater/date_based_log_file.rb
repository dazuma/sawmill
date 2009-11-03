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
      # <tt>:basedir</tt>::
      #   The base directory used if the filepath is a relative path.
      #   If not specified, the current working directory is used.
      # <tt>:path_prefix</tt>::
      #   The logfile path prefix.
      #   In the filename "rails.2009-10-11.log", the prefix is "rails".
      #   If not specified, defaults to "sawmill".
      # <tt>:path_suffix</tt>::
      #   The logfile name prefix.
      #   In the filename "rails.2009-10-11.log", the suffix is ".log".
      #   If not specified, defaults to ".log".
      # <tt>:local_datestamps</tt>::
      #   If true, use the local timezone to create datestamps.
      #   The default is to use UTC.
      # <tt>:encoding</tt>::
      #   Specify an encoding name for file data. (Ruby 1.9 only)
      #   If not specified, uses the default external encoding.
      
      def initialize(options_)
        @turnover_frequency = options_[:turnover_frequency] || :none
        @prefix = ::File.expand_path(options_[:path_prefix] || options_[:prefix] || 'sawmill',
                                     options_[:basedir] || options_[:dirname] || ::Dir.getwd)
        @suffix = options_[:path_suffix] || options_[:suffix] || '.log'
        @local_datestamps = options_[:local_datestamps]
        @date_pattern =
          case @turnover_frequency
          when :yearly then "%Y"
          when :monthly then "%Y-%m"
          when :daily then "%Y-%m-%d"
          when :hourly then "%Y-%m-%d-%H"
          else nil
          end
        @mode = 'a'
        if defined?(::Encoding) && (encoding_ = options_[:encoding])
          @mode << ":#{encoding_}"
        end
      end
      
      
      # Implements the rotation strategy contract.
      
      def preferred_handle
        if @date_pattern
          time_ = ::Time.now
          time_.utc unless @local_datestamps
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
        file_ = ::File.open(path_, @mode)
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
