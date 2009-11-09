# -----------------------------------------------------------------------------
# 
# Sawmill entry point
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


require 'blockenspiel'


dir_ = ::File.expand_path('sawmill', ::File.dirname(__FILE__))

includes_ = [
 'version',
 'util/queue',
 'util/heap',
 'util/processor_tools',
 'errors',
 'level',
 'entry',
 'entry_classifier',
 'entry_processor',
 'entry_processor/conditionals',
 'entry_processor/simple_queue',
 'entry_processor/filter_by_basic_fields',
 'entry_processor/filter_by_block',
 'entry_processor/build_records',
 'entry_processor/format',
 'entry_processor/count_entries',
 'entry_processor/compile_report',
 'record',
 'record_processor',
 'record_processor/conditionals',
 'record_processor/filter_by_record_id',
 'record_processor/filter_by_attributes',
 'record_processor/filter_by_block',
 'record_processor/simple_queue',
 'record_processor/decompose',
 'record_processor/format',
 'record_processor/count_records',
 'record_processor/compile_report',
 'parser',
 'multi_parser',
 'logger',
 'rotater',
 'rotater/base',
 'rotater/date_based_log_file',
 'rotater/shifting_log_file',
 'log_record_middleware',
 'interface',
]
includes_.each{ |file_| require "#{dir_}/#{file_}" }
