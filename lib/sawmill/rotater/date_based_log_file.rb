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
      # [<tt>:turnover_frequency</tt>]
      #   How often the log files should turn over. Allowed values are:
      #   <tt>:yearly</tt>, <tt>:monthly</tt>, <tt>:daily</tt>,
      #   <tt>:hourly</tt>, and <tt>:never</tt>.
      # [<tt>:basedir</tt>]
      #   The base directory used if the filepath is a relative path.
      #   If not specified, the current working directory is used.
      # [<tt>:path_prefix</tt>]
      #   The logfile path prefix.
      #   In the filename "rails.2009-10-11.log", the prefix is "rails".
      #   If not specified, defaults to "sawmill".
      # [<tt>:path_suffix</tt>]
      #   The logfile name prefix.
      #   In the filename "rails.2009-10-11.log", the suffix is ".log".
      #   If not specified, defaults to ".log".
      # [<tt>:uniquifier</tt>]
      #   If provided, log files are never reopened. (That is, they are
      #   opened with ::File::CREAT | ::File::EXCL.) The value of this
      #   parameter must be a proc that returns an actual file name to
      #   attempt to open. This proc is called repeatedly until it either
      #   returns a file path that does not yet exist, or signals failure
      #   by returning nil. See the session on Uniquifiers below.
      # [<tt>:local_datestamps</tt>]
      #   If true, use the local timezone to create datestamps.
      #   The default is to use UTC.
      #
      # === Uniquifiers
      #
      # DateBasedLogFile provides a facility for ensuring that log files
      # are written to by only one process, by generating unique file
      # names for log files. This facility is useful, for example, if you
      # are deploying via Phusion Passenger where you may have a variable
      # number of rails processes, and you want each process to own its
      # own logfile so entries in log records are not interleaved.
      #
      # To activate this feature, pass a proc to the <tt>:uniquifier</tt>
      # option. When DateBasedLogFile wants to open a log file for
      # writing, it first calls this proc. The proc should return a file
      # path to try opening. DateBasedLogFile then tries to open the file
      # with ::File::CREAT | ::File::EXCL, which will succeed only if the
      # file has not already been created (e.g. by another process). If
      # the file already exists, the proc will be called again, and
      # repeatedly until it either returns a path that has not yet been
      # created, or nil indicating that it has given up.
      #
      # The proc is passed a single hash that provides information about
      # what path to generate, as well as space for the proc to store any
      # state it wishes to persist through the process. These keys are
      # given to the proc by DateBasedLogFile. Any other keys are
      # available for use by the proc.
      #
      # [<tt>:original_path</tt>]
      #   The original file path generated by DateBasedLogFile, which
      #   would have been used if there were no uniquifier.
      # [<tt>:last_path</tt>]
      #   The last path generated by the proc, or nil if this is the
      #   first time this proc is called for a particular logfile.
      # [<tt>:basedir</tt>]
      #   The basedir of the DateBasedLogFile.
      # [<tt>:path_prefix</tt>]
      #   The path_prefix of the DateBasedLogFile.
      # [<tt>:path_suffix</tt>]
      #   The path_suffix of the DateBasedLogFile.

      def initialize(options_)
        @turnover_frequency = options_[:turnover_frequency] || :none
        @basedir = options_[:basedir] || options_[:dirname] || ::Dir.getwd
        @prefix = options_[:path_prefix] || options_[:prefix] || 'sawmill'
        @suffix = options_[:path_suffix] || options_[:suffix] || '.log'
        @suffix = ".#{@suffix}" unless @suffix.length == 0 || @suffix[0,1] == '.'
        @uniquifier = options_[:uniquifier]
        @local_datestamps = options_[:local_datestamps]
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
          time_.utc unless @local_datestamps
          time_.strftime(@date_pattern)
        else
          ''
        end
      end


      # Implements the rotation strategy contract.

      def open_handle(handle_)
        path_ = ::File.expand_path(@date_pattern ? "#{@prefix}.#{handle_}#{@suffix}" : @prefix+@suffix, @basedir)
        file_ = nil
        if @uniquifier
          hash_ = {:path_prefix => @prefix, :path_suffix => @suffix, :basedir => @basedir, :original_path => path_.dup, :last_path => nil}
          until file_
            path_ = @uniquifier.call(hash_)
            unless path_
              raise Errors::NoUniqueLogFileError, "Could not find a unique log file path for #{hash_.inspect}"
            end
            begin
              file_ = ::File.open(path_, ::File::CREAT | ::File::EXCL | ::File::WRONLY)
            rescue ::Errno::EEXIST
              hash_[:last_path] = path_
            end
          end
        else
          file_ = ::File.open(path_, 'a')
        end
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


      class << self


        # Returns a simple uniquifier that inserts an incrementing number
        # before the path suffix. i.e. if the non-uniquified filename is
        # "rails.2009-10-11.log", then these names are generated:
        #
        #  rails.2009-10-11.0.log
        #  rails.2009-10-11.1.log
        #  rails.2009-10-11.2.log
        #  etc.
        #
        # The following options are available:
        #
        # [<tt>:min_digits</tt>]
        #   If provided, indicates the minimum number of digits for the
        #   unique number. For example, if :digits is set to 2, these
        #   names are generated:
        #    rails.2009-10-11.00.log
        #    rails.2009-10-11.01.log
        #    rails.2009-10-11.02.log
        #    ...
        #    rails.2009-10-11.09.log
        #    rails.2009-10-11.10.log
        #    rails.2009-10-11.11.log
        #    ...
        #    rails.2009-10-11.99.log
        #    rails.2009-10-11.100.log
        #    rails.2009-10-11.101.log
        #    etc.
        #   The default is 1.
        # [<tt>:start_value</tt>]
        #   The first value for the unique number. Default is 0.

        def simple_uniquifier(opts_={})
          if (digits_ = opts_[:min_digits])
            pattern_ = "%s.%0#{digits_.to_i}d%s"
          else
            pattern_ = "%s.%d%s"
          end
          ::Proc.new do |hash_|
            if hash_[:last_path]
              hash_[:value] += 1
            else
              suffix_ = hash_[:path_suffix]
              orig_ = hash_[:original_path]
              suffix_len_ = suffix_.length
              if suffix_len_ > 0 && orig_[-suffix_len_, suffix_len_] == suffix_
                pre_ = orig_[0, orig_.length - suffix_len_]
                post_ = suffix_
              else
                pre_ = orig_
                post_ = ''
              end
              hash_[:value] = opts_[:start_value].to_i
              hash_[:pre] = pre_
              hash_[:post] = post_
            end
            pattern_ % [hash_[:pre], hash_[:value], hash_[:post]]
          end
        end


      end


    end


  end

end
