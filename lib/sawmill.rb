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


module Sawmill
end


require 'sawmill/version'
require 'sawmill/util/queue'
require 'sawmill/util/heap'
require 'sawmill/util/processor_tools'
require 'sawmill/errors'
require 'sawmill/level'
require 'sawmill/entry'
require 'sawmill/entry_classifier'
require 'sawmill/entry_processor'
require 'sawmill/entry_processor/conditionals'
require 'sawmill/entry_processor/simple_queue'
require 'sawmill/entry_processor/filter_by_basic_fields'
require 'sawmill/entry_processor/filter_by_block'
require 'sawmill/entry_processor/build_records'
require 'sawmill/entry_processor/format'
require 'sawmill/entry_processor/count_entries'
require 'sawmill/entry_processor/compile_report'
require 'sawmill/entry_processor/interpret_stats'
require 'sawmill/record'
require 'sawmill/record_processor'
require 'sawmill/record_processor/conditionals'
require 'sawmill/record_processor/filter_by_record_id'
require 'sawmill/record_processor/filter_by_attributes'
require 'sawmill/record_processor/filter_by_block'
require 'sawmill/record_processor/simple_queue'
require 'sawmill/record_processor/decompose'
require 'sawmill/record_processor/format'
require 'sawmill/record_processor/count_records'
require 'sawmill/record_processor/compile_report'
require 'sawmill/parser'
require 'sawmill/multi_parser'
require 'sawmill/logger'
require 'sawmill/rotater'
require 'sawmill/rotater/base'
require 'sawmill/rotater/date_based_log_file'
require 'sawmill/rotater/shifting_log_file'
require 'sawmill/log_record_middleware'
require 'sawmill/stats_middleware'
require 'sawmill/interface'
