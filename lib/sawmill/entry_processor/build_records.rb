# -----------------------------------------------------------------------------
# 
# Sawmill entry processor that builds log records
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
  
  module EntryProcessor
    
    
    # An entry processor that builds log records from a stream of entries,
    # and passes those log records to the given record processor.
    
    class BuildRecords < Base
      
      
      # Create record builder emitting to the given record processor.
      # 
      # Recognized options include:
      # 
      # [<tt>:emit_incomplete_records_on_finish</tt>]
      #   When the processor is finished, any records that are still not
      #   complete will be emitted to the record processor anyway, even
      #   in their incomplete state.
      
      def initialize(processor_, opts_={})
        @processor = processor_
        @records = {}
        @emit_incomplete_records_on_finish = opts_[:emit_incomplete_records_on_finish]
      end
      
      
      # Emit all currently incomplete records immediately in their
      # incomplete state. This clears those incomplete records, so note that
      # if they do get completed later, they will not be re-emitted.
      
      def emit_incomplete_records
        if @records
          @records.values.each do |record_|
            @processor.record(record_)
          end
          @records.clear
        end
      end
      
      
      def begin_record(entry_)
        return unless @records
        record_id_ = entry_.record_id
        if @records.include?(record_id_)
          @processor.extra_entry(entry_)
          false
        else
          @records[record_id_] = Record.new([entry_])
          true
        end
      end
      
      
      def end_record(entry_)
        return unless @records
        record_ = @records.delete(entry_.record_id)
        if record_
          record_.add_entry(entry_)
          @processor.record(record_)
          true
        else
          @processor.extra_entry(entry_)
          false
        end
      end
      
      
      def message(entry_)
        return unless @records
        record_ = @records[entry_.record_id]
        if record_
          record_.add_entry(entry_)
          true
        else
          @processor.extra_entry(entry_)
          false
        end
      end
      
      
      def attribute(entry_)
        return unless @records
        record_ = @records[entry_.record_id]
        if record_
          record_.add_entry(entry_)
          true
        else
          @processor.extra_entry(entry_)
          false
        end
      end
      
      
      def unknown_data(entry_)
        return unless @records
        @processor.extra_entry(entry_)
        false
      end
      
      
      def finish
        if @records
          emit_incomplete_records if @emit_incomplete_records_on_finish
          @records = nil
          @processor.finish
        else
          nil
        end
      end
      
      
    end
    
    
  end
  
  
  # Sawmill::RecordBuilder is an alternate name for
  # Sawmill::EntryProcessor::BuildRecords
  RecordBuilder = EntryProcessor::BuildRecords
  
  
end
