# -----------------------------------------------------------------------------
# 
# Sawmill stats middleware class
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
  
  
  # A Rack middleware that writes a stats log.
  # Insert this in your Rack stack to generate a stats log.
  
  class StatsMiddleware
    
    
    # Create a middleware object for Rack.
    # 
    # If you do not provide a logger object, one will be generated for you
    # that simply logs to STDOUT.
    # 
    # Recognized options include:
    # 
    # [<tt>:level</tt>]
    #   The level to log at. Default is <tt>:ANY</tt>.
    # [<tt>:stats_data_key</tt>]
    #   The name of a rack environment key where the stats data should
    #   be stored. If not specified, defaults to "sawmill.stats_data".
    # [<tt>:record_id_key</tt>]
    #   The name of a rack environment key where the record ID can be
    #   obtained. If not specified, defaults to "sawmill.record_id".
    # [<tt>:start_time_stat</tt>]
    #   If present, stores the starting timestamp for the request in the
    #   given stat key. If absent, does not store this information.
    # [<tt>:end_time_stat</tt>]
    #   If present, stores the ending timestamp for the request in the
    #   given stat key. If absent, does not store this information.
    # [<tt>:elapsed_time_stat</tt>]
    #   If present, stores the elapsed time for the request in the
    #   given stat key. If absent, does not store this information.
    # [<tt>:log_record_id_stat</tt>]
    #   If present, stores the log record ID for the request in the
    #   given stat key. If absent, does not store this information.
    # [<tt>:pre_logger</tt>]
    #   A proc that is called at the start of the request, and passed the
    #   logger and the rack environment. Optional.
    #   If a proc is provided and returns false, then stats logging is
    #   canceled for this request. Furthermore, any post_logger will
    #   not be called.
    # [<tt>:post_logger</tt>]
    #   A proc that is called at the end of the request, and passed the
    #   logger and the rack environment. Optional.
    #   If a proc is provided and returns false, then stats logging is
    #   canceled for this request.
    
    def initialize(app_, logger_=nil, level_=nil, opts_={})
      @app = app_
      @logger = logger_ || Logger.new(:progname => 'stats', :processor => Formatter.new(::STDOUT))
      @level = level_ || :ANY
      @stats_data_key = opts_[:stats_data_key] || 'sawmill.stats_data'
      @record_id_key = opts_[:record_id_key] || 'sawmill.record_id'
      @start_time_stat = opts_[:start_time_stat]
      @end_time_stat = opts_[:end_time_stat]
      @elapsed_time_stat = opts_[:elapsed_time_stat]
      @log_record_id_stat = opts_[:log_record_id_stat]
      @pre_logger = opts_[:pre_logger]
      @post_logger = opts_[:post_logger]
    end
    
    
    def call(env_)
      env_[@stats_data_key] = stats_data_ = {}
      start_time_ = ::Time.now.utc
      if @start_time_stat
        stats_data_[@start_time_stat.to_s] = start_time_.strftime('%Y-%m-%dT%H:%M:%S.') + ('%06d' % start_time_.usec) + 'Z'
      end
      enable_log_ = true
      if @pre_logger
        enable_log_ &&= @pre_logger.call(stats_data_, env_)
      end
      begin
        return @app.call(env_)
      ensure
        if enable_log_
          if @log_record_id_stat
            stats_data_[@log_record_id_stat.to_s] = env_[@record_id_key]
          end
          if @post_logger
            enable_log_ &&= @post_logger.call(stats_data_, env_)
          end
          if enable_log_
            end_time_ = ::Time.now.utc
            if @end_time_stat
              stats_data_[@end_time_stat.to_s] = end_time_.strftime('%Y-%m-%dT%H:%M:%S.') + ('%06d' % end_time_.usec) + 'Z'
            end
            if @elapsed_time_stat
              stats_data_[@elapsed_time_stat.to_s] = end_time_ - start_time_
            end
            @logger.add(@level, ::JSON.dump(stats_data_))
          end
        end
      end
    end
    
    
  end
  
  
end
