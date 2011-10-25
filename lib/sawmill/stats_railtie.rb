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
  
  
  # Railtie that sets up a stats logger. Installs a
  # Sawmill::StatsMiddleware to enable a stats log.
  # 
  # To install into a Rails app, include this line in your
  # config/application.rb:
  #   require 'sawmill/stats_railtie'
  # It should appear before your application configuration.
  # 
  # You can then configure the stats logs using the standard rails
  # configuration mechanism. The configuration lives in the
  # config.sawmill_stats configuration namespace. See
  # Sawmill::StatsRailtie::Configuration for the list of options.
  
  class StatsRailtie < ::Rails::Railtie
    
    
    # Configuration options. These are attributes of config.sawmill_stats.
    
    class Configuration
      
      def initialize  # :nodoc:
        @logfile = ::STDERR
        @fractional_second_digits = 2
        @level_width = nil
        @local_time = false
        @iso_8601_time = false
        @length_limit = nil
        @level = :ANY
        @progname = 'rails'
        @stats_data_key = 'sawmill.stats_hash'
        @start_time_stat = nil
        @end_time_stat = nil
        @elapsed_time_stat = nil
        @log_record_id_stat = nil
        @pre_logger = nil
        @post_logger = nil
        @generated_logger = nil
      end
      
      # The log file to write to. This should be either an IO object, or
      # a Sawmill::Rotater. Default is STDERR.
      attr_accessor :logfile
      
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
      attr_accessor :progname
      
      # This option is passed to Sawmill::StatsMiddleware::new
      attr_accessor :stats_data_key
      # This option is passed to Sawmill::StatsMiddleware::new
      attr_accessor :start_time_stat
      # This option is passed to Sawmill::StatsMiddleware::new
      attr_accessor :end_time_stat
      # This option is passed to Sawmill::StatsMiddleware::new
      attr_accessor :elapsed_time_stat
      # This option is passed to Sawmill::StatsMiddleware::new
      attr_accessor :log_record_id_stat
      
      # Access the logger after it is generated
      attr_reader :generated_logger
      
      
      def pre_logger(proc_=false, &block_)
        if block_
          @pre_logger = block_
        elsif proc_ != false
          @pre_logger = proc_
        end
        @pre_logger
      end
      attr_writer :pre_logger
      
      def post_logger(proc_=false, &block_)
        if block_
          @post_logger = block_
        elsif proc_ != false
          @post_logger = proc_
        end
        @post_logger
      end
      attr_writer :post_logger
      
      def _set_generated_logger(logger_)  # :nodoc:
        @generated_logger = logger_
      end
      
    end
    
    
    config.sawmill_stats = Configuration.new
    
    
    initializer :initialize_sawmill_stats, :before => :initialize_logger do |app_|
      main_config_ = app_.config
      stats_config_ = main_config_.sawmill_stats
      sawmill_config_ = main_config_.respond_to?(:sawmill) ? main_config_.sawmill : nil
      formatter_ = Formatter.new(stats_config_.logfile || ::STDERR,
        :fractional_second_digits => stats_config_.fractional_second_digits,
        :level_width => stats_config_.level_width,
        :local_time => stats_config_.local_time,
        :iso_8601_time => stats_config_.iso_8601_time,
        :length_limit => stats_config_.length_limit)
      logger_ = Logger.new(
        :processor => formatter_,
        :level => stats_config_.level,
        :progname => stats_config_.progname)
      stats_config_._set_generated_logger(logger_)
      app_.config.middleware.insert_after(::Rack::Runtime,
        ::Sawmill::StatsMiddleware, logger_, stats_config_.level,
        :log_record_id_stat => sawmill_config_ && stats_config_.log_record_id_stat ?
          stats_config_.log_record_id_stat : nil,
        :stats_data_key => stats_config_.stats_data_key,
        :start_time_stat => stats_config_.start_time_stat,
        :end_time_stat => stats_config_.end_time_stat,
        :elapsed_time_stat => stats_config_.elapsed_time_stat,
        :pre_logger => stats_config_.pre_logger,
        :post_logger => stats_config_.post_logger)
    end
    
    
  end
  
  
end
