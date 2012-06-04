# -----------------------------------------------------------------------------
#
# Sawmill log rotation utility
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


require 'monitor'


module Sawmill


  # The Sawmill Rotater provides log rotation services for logfile
  # formatting, supporting several different log rotation strategies.
  #
  # The formatter implemented by Sawmill::EntryProcessor::Format already
  # recognizes a Rotater as a supported destination, and automatically
  # interfaces with it to ensure that log records aren't split into
  # multiple files by rotation.
  #
  # You may also interface with a rotater manually. The core of rotater
  # usage is the Channel, which lets you ensure that groups of log
  # entries end up in the same log file regardless of log rotation.
  # Generally, to use a rotater, you obtain one or more channels and
  # write formatted entries to them, either telling them explicitly
  # where the allowable file breaks are, or by letting the rotater
  # break the file anywhere it wants. See the create_channel method
  # and the Channel object for more details.

  class Rotater

    # :stopdoc:
    SUPPORTS_ENCODING = defined?(::Encoding)
    ENCODING_OPTS = {:invalid => :replace, :undef => :replace}
    # :startdoc:


    # Create a rotater using the given rotation strategy.
    # See Sawmill::Rotater::DateBasedLogFile and
    # Sawmill::Rotater::ShiftingLogFile for examples of common strategies.
    #
    # The rotation strategy can be passed as an object or as a class with a
    # set of options that will be used to instantiate the strategy.
    # In addition to those options, the following options are recognized:
    #
    # [<tt>:omit_directives</tt>]
    #   If true, omit standard logfile directives. Default is false.
    # [<tt>:concurrent_writes</tt>]
    #   Set this to true if you expect multiple processes to attempt to
    #   write to the same log file simultaneously. This option causes the
    #   rotater to surround writes with an acquisition of the cooperative
    #   filesystem lock (if available) for the logfile, in an attempt to
    #   prevent lines from interleaving in one another. Default is false.
    # [<tt>:encoding</tt>]
    #   Specify an encoding for file data. (Ruby 1.9 only).
    #   You may pass either an encoding object or an encoding name.
    #   If not specified, writes raw bytes (e.g. defaults to ASCII-8BIT).

    def initialize(io_manager_, opts_={})
      @omit_directives = opts_.delete(:omit_directives)
      @concurrent_writes = opts_.delete(:concurrent_writes)
      if SUPPORTS_ENCODING
        @encoding = opts_.delete(:encoding)
        if @encoding && !@encoding.respond_to?(:name)
          @encoding = ::Encoding.find(@encoding)
        end
      end
      if io_manager_.kind_of?(::Class)
        @io_manager = io_manager_.new(opts_)
      else
        @io_manager = io_manager_
      end
      @handles ||= {}
      @mutex ||= ::Monitor.new
    end


    # Create a new Channel for this Rotater. See Sawmill::Rotater::Channel
    # for details on the Channel object.
    #
    # The following options are recognized:
    #
    # [<tt>:auto_rotate</tt>]
    #   Put the channel in auto-rotate mode. In this mode, the rotater is
    #   allowed to rotate the logfile at any time for that channel. It is
    #   the equivalent of calling check_rotate on the channel after every
    #   write. Default is false.

    def create_channel(opts_={})
      Channel.new(self, opts_)
    end


    def _write_to_stream(io_, str_)  # :nodoc:
      if SUPPORTS_ENCODING && @encoding
        str_ = str_.encode(@encoding, ENCODING_OPTS)
      end
      if @concurrent_writes
        begin
          io_.flock(::File::LOCK_EX)
          io_.write(str_)
        ensure
          io_.flock(::File::LOCK_UN)
        end
      else
        io_.write(str_)
      end
    end


    def _obtain_handle  # :nodoc:
      handle_ = @io_manager.preferred_handle
      if @handles.include?(handle_)
        @handles[handle_][2] += 1
      else
        io_ = @io_manager.open_handle(handle_)
        unless @omit_directives
          _write_to_stream(io_, "# sawmill_format: version=1\n")
          if SUPPORTS_ENCODING
            encoding_ = @encoding || ::Encoding.default_external
            _write_to_stream(io_, "# sawmill_format: encoding=#{encoding_.name}\n")
          end
        end
        @handles[handle_] = [handle_, io_, 1]
      end
      handle_
    end


    def _release_handle(handle_)  # :nodoc:
      info_ = @handles[handle_]
      info_[2] -= 1
      if info_[2] == 0
        @io_manager.close_handle(handle_, info_[1])
        @handles.delete(handle_)
      end
      nil
    end


    def _check_rotate_handle(handle_)  # :nodoc:
      if handle_ != @io_manager.preferred_handle
        _release_handle(handle_)
        _obtain_handle
      else
        handle_
      end
    end


    def _do_open  # :nodoc:
      @mutex.synchronize do
        _obtain_handle
      end
    end


    def _do_write(handle_, str_, auto_rotate_)  # :nodoc:
      @mutex.synchronize do
        @io_manager.before_write
        if auto_rotate_
          handle_ = _check_rotate_handle(handle_)
        end
        info_ = @handles[handle_]
        _write_to_stream(info_[1], str_)
        handle_
      end
    end


    def _do_close(handle_)  # :nodoc:
      @mutex.synchronize do
        _release_handle(handle_)
      end
    end


    def _do_check_rotate(handle_)  # :nodoc:
      @mutex.synchronize do
        _check_rotate_handle(handle_)
      end
    end


    # A channel is a lightweight object that responds to the write and close
    # methods; that is, it is sufficient for Sawmill::Formatter.
    #
    # When a channel is opened, it locks down a path to the logfile and
    # ensures that the logfile will not rotate out from under it; that is,
    # writes to a channel are ensured to end up in the same physical file.
    #
    # You may choose, at intervals, to explicitly tell the channel that it
    # is okay to rotate the logfile now, by calling check_rotate.
    #
    # You must close a channel when you are done with it. Closing a channel
    # does not close the underlying logfile, but instead tells the rotater
    # that you are done with this channel and that the logfile is free to
    # rotate independent of it.
    #
    # You may have any number of channels open at any time, each on a
    # different rotation schedule. Each may possibly be writing to different
    # files in the rotation at any time, but this is all done automatically
    # behind the scenes.

    class Channel

      def initialize(rotater_, opts_={})  # :nodoc:
        @rotater = rotater_
        @auto_rotate = opts_[:auto_rotate]
        @io_handle = @rotater._do_open
      end


      # Write a string to this channel.

      def write(str_)
        if @io_handle
          @rotater._do_write(@io_handle, str_, @auto_rotate)
        end
      end


      # Close this channel, telling the rotater that this channel no longer
      # needs to constrain the log rotation.

      def close
        if @io_handle
          @rotater._do_close(@io_handle)
          @io_handle = nil
        end
      end


      # Manually tell the rotater that this channel is at a stopping point
      # and that the log file may rotate at this time.

      def check_rotate
        if @io_handle
          @io_handle = @rotater._do_check_rotate(@io_handle)
        end
      end


    end


  end

end
