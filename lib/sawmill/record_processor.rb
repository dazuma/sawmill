# -----------------------------------------------------------------------------
#
# Sawmill record processor interface
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


  # Entry processors are objects that receive a stream of log records and
  # perform some action. Some processors perform their own action, while
  # others could filter records and forward them to other processors.
  #
  # The API contract for a record processor is specified by the class
  # Sawmill::RecordProcessor::Base. Processors could subclass that base
  # class, or could just duck-type the methods.
  #
  # Sawmill's basic record processor classes live into this module's
  # namespace, but this is not a requirement for your own processors.

  module RecordProcessor


    class Builder  # :nodoc:
      include ::Blockenspiel::DSL
    end


    # A base class for record processors.
    #
    # Record processors need not necessarily subclass this class, but should
    # at least duck-type the methods.
    #
    # If a class subclasses this class, *and* lives in the RecordProcessor
    # namespace, then it will automatically be available in the build
    # interface. See RecordProcessor#build.

    class Base


      # Receive and process a Sawmill::Record.

      def record(record_)
        true
      end


      # Receive and process an entry that falls outside a record.

      def extra_entry(entry_)
        true
      end


      # Close down the processor, perform any finishing tasks, and return
      # any final calculated value.
      #
      # After this is called, the processor should ignore any further entries.
      #
      # The return value can be used to communicate a final computed value,
      # analysis report, or other data back to the caller. It may also be
      # nil, signalling no finish value.
      #
      # Note that some processors function to multiplex other processors. In
      # such a case, their finish value needs to be an aggregate of the
      # values returned by their descendants. To handle these cases, we
      # define a protocol for finish values. A finish value may be nil, an
      # Array, or another kind of object. Nil means "no value" and thus can
      # be ignored by a processor that aggregates other values. An Array
      # indicates an aggregation; if finish returns an array, it is _always_
      # an aggregation of actual values. Any other kind of object is to be
      # interpreted as a single value. This means that if you want to
      # actually return an array _as_ a value, you must wrap it in another
      # array, indicating "an array of one finish value, and that finish
      # value also happens to be an array itself".

      def finish
        nil
      end


      def self.inherited(subclass_)  # :nodoc:
        if subclass_.name =~ /^Sawmill::RecordProcessor::([^:]+)$/
          name_ = $1
          Builder.class_eval do
            define_method(name_) do |*args_|
              subclass_.new(*args_)
            end
          end
        end
      end


      # Add a method to the processor building DSL. You may call this method
      # in the DSL to create an instance of this record processor.
      # You must pass a method name that begins with a lower-case letter or
      # underscore.
      #
      # Processors that subclass Sawmill::RecordProcessor::Base and live in
      # the Sawmill::RecordProcessor namespace will have their class name
      # automatically added to the DSL. This method is primarily for other
      # processors that do not live in that module namespace.
      #
      # See Sawmill::RecordProcessor#build for more information.
      #
      # Raises Sawmill::Errors::DSLMethodError if the given name is already
      # taken.

      def self.add_dsl_method(name_)
        klass_ = self
        if name_.to_s !~ /^[a-z_]/
          raise ::ArgumentError, "Method name must begin with a lower-case letter or underscore"
        end
        if Builder.method_defined?(name_)
          raise Errors::DSLMethodError, "Method #{name_} already defined"
        end
        Builder.class_eval do
          define_method(name_) do |*args_|
            klass_.new(*args_)
          end
        end
      end


      private

      def _interpret_processor_array(param_)  # :nodoc:
        param_.flatten.map{ |processor_| _interpret_processor(processor_) }
      end

      def _interpret_processor(param_)  # :nodoc:
        case param_
        when ::Class
          param_.new
        when Base
          param_
        else
          raise ::ArgumentError, "Unknown processor object of type #{param_.class.name}"
        end
      end


    end


    # A convenience DSL for building sets of processors. This is typically
    # useful for constructing if-expressions using the boolean operation
    # processors.
    #
    # Every record processor that lives in the Sawmill::RecordProcessor
    # module and subclasses Sawmill::RecordProcessor::Base can be
    # instantiated by using its name as a function call. Other processors
    # may also add themselves to the DSL by calling
    # Sawmill::RecordProcessor::Base#add_dsl_method.
    #
    # For example:
    #
    #  Sawmill::RecordProcessor.build do
    #    If(Or(FilterByRecordId('12345678'), FilterByRecordId('abcdefg')),
    #       Format(STDOUT))
    #  end

    def self.build(&block_)
      ::Blockenspiel.invoke(block_, Builder.new)
    end


  end


end
