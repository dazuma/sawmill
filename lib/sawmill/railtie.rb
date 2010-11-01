# -----------------------------------------------------------------------------
# 
# Sawmill railtie
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


require 'sawmill'
require 'rails/railtie'


module Sawmill
  
  
  # Railtie that replaces the default Rails logger with a Sawmill logger.
  # Sets the Rails logger to a Sawmill::Logger, and installs a
  # Sawmill::LogRecordMiddleware to enable record-based logging.
  # 
  # To install into a Rails app, include this line in your
  # config/application.rb:
  #   require 'sawmill/railtie'
  # It should appear before your application configuration.
  # 
  # You can then configure sawmill using the standard rails configuration
  # mechanism. The sawmill configuration lives in the config.sawmill
  # configuration namespace. See Sawmill::Railtie::Configuration for the
  # configuration options.
  
  class Railtie < ::Rails::Railtie
    
    
    # Configuration options. These are attributes of config.sawmill.
    
    class Configuration
      
      def initialize  # :nodoc:
        @logfile = ::STDERR
        @formatter_options = {}
        @logger_options = {}
        @include_id = false
        @fractional_second_digits = 2
        @level_width = nil
        @local_time = false
        @iso_8601_time = false
        @length_limit = nil
        @level = :INFO
        @attribute_level = nil
        @progname = 'rails'
        @record_progname = nil
        @record_id_generator = nil
        @request_id_key = 'sawmill.request_id'
        @start_time_attribute = nil
        @end_time_attribute = nil
      end
      
      # The log file to write to. This should be either an IO object, or
      # a Sawmill::Rotater. Default is STDERR.
      attr_accessor :logfile
      
      # This option is passed to Sawmill::EntryProcessor::Format::new
      attr_accessor :include_id
      # This option is passed to Sawmill::EntryProcessor::Format::new
      attr_accessor :fractional_second_digits
      # This option is passed to Sawmill::EntryProcessor::Format::new
      attr_accessor :level_width
      # This option is passed to Sawmill::EntryProcessor::Format::new
      attr_accessor :local_time
      # This option is passed to Sawmill::EntryProcessor::Format::new
      attr_accessor :iso_8601_time
      # This option is passed to Sawmill::EntryProcessor::Format::new
      attr_accessor :length_limit
      
      # This option is passed to Sawmill::Logger::new
      attr_accessor :level
      # This option is passed to Sawmill::Logger::new
      attr_accessor :attribute_level
      # This option is passed to Sawmill::Logger::new
      attr_accessor :progname
      # This option is passed to Sawmill::Logger::new
      attr_accessor :record_progname
      # This option is passed to Sawmill::Logger::new
      attr_accessor :record_id_generator
      
      # This option is passed to Sawmill::LogRecordMiddleware::new
      attr_accessor :request_id_key
      # This option is passed to Sawmill::LogRecordMiddleware::new
      attr_accessor :start_time_attribute
      # This option is passed to Sawmill::LogRecordMiddleware::new
      attr_accessor :end_time_attribute
      
    end
    
    
    config.sawmill = Configuration.new
    
    
    initializer :initialize_sawmill, :before => :initialize_logger do |app_|
      myconfig_ = app_.config.sawmill
      formatter_ = Formatter.new(myconfig_.logfile || ::STDERR,
                                 :include_id => myconfig_.include_id,
                                 :fractional_second_digits => myconfig_.fractional_second_digits,
                                 :level_width => myconfig_.level_width,
                                 :local_time => myconfig_.local_time,
                                 :iso_8601_time => myconfig_.iso_8601_time,
                                 :length_limit => myconfig_.length_limit)
      logger_ = Logger.new(:processor => formatter_,
                           :level => myconfig_.level,
                           :attribute_level  => myconfig_.attribute_level,
                           :progname => myconfig_.progname,
                           :record_progname => myconfig_.record_progname,
                           :record_id_generator => myconfig_.record_id_generator)
      app_.config.logger = logger_
      app_.config.middleware.swap(::Rails::Rack::Logger,
                                  ::Sawmill::LogRecordMiddleware, logger_,
                                  :request_id_key => myconfig_.request_id_key,
                                  :start_time_attribute => myconfig_.start_time_attribute,
                                  :end_time_attribute => myconfig_.end_time_attribute)
    end
    
    
  end
  
  
end
