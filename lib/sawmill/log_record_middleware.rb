# -----------------------------------------------------------------------------
# 
# Sawmill logger class
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
  
  
  # A Rack middleware that starts and ends a log record.
  # Insert this in your Rack stack to wrap requests in a log record.
  
  class LogRecordMiddleware
    
    
    # Create a middleware object for Rack.
    # 
    # If you do not provide a logger object, one will be generated for you
    # that simply logs to STDOUT.
    # 
    # Recognized options include:
    # 
    # <tt>:request_id_key</tt>::
    #   The name of a rack environment key where the record ID should be
    #   stored. If not specified, defaults to "sawmill.request_id".
    # <tt>:start_time_attribute</tt>::
    #   If present, logs an attribute with this name with the starting
    #   timestamp for the request. If absent, does not log this attribute.
    # <tt>:end_time_attribute</tt>::
    #   If present, logs an attribute with this name with the ending
    #   timestamp for the request. If absent, does not log this attribute.
    
    def initialize(app_, logger_=nil, opts_={})
      @app = app_
      @logger = logger_ || Logger.new(:progname => 'rack', :processor => ::Sawmill::Formatter.new(STDOUT))
      @request_id_key = opts_[:request_id_key] || 'sawmill.request_id'
      @start_time_attribute = opts_[:start_time_attribute]
      @end_time_attribute = opts_[:end_time_attribute]
    end
    
    
    def call(env_)
      env_[@request_id_key] = @logger.begin_record
      if @start_time_attribute
        time_ = Time.now.utc
        @logger.set_attribute(@start_time_attribute, time_.strftime('%Y-%m-%dT%H:%M:%S.') + ('%06d' % time_.usec) + 'Z')
      end
      begin
        return @app.call(env_)
      ensure
        if @end_time_attribute
          time_ = Time.now.utc
          @logger.set_attribute(@end_time_attribute, time_.strftime('%Y-%m-%dT%H:%M:%S.') + ('%06d' % time_.usec) + 'Z')
        end
        @logger.end_record
      end
    end
    
    
  end
  
  
end