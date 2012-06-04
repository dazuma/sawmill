# -----------------------------------------------------------------------------
#
# Sawmill level class
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


  # Level objects represent logging levels, sometimes known as severities.
  #
  # A level object has a name and a numeric value. The name controls how the
  # level is represented in a logfile. The value indicates its severity rank
  # compared to other levels.
  #
  # Levels are organized into groups. Levels are comparable with one another
  # if they are part of the same group.

  class Level


    def initialize(group_, name_, value_)  # :nodoc:
      @group = group_
      @name = name_
      @value = value_
    end


    # The LevelGroup of which this Level is a member
    attr_reader :group

    # The name of the level, as a string.
    attr_reader :name

    # The numeric value of the level.
    attr_reader :value


    # Compare this level with another level of the same group.
    def <=>(obj_)
      if obj_.respond_to?(:value) && obj_.respond_to?(:group)
        @group == obj_.group ? @value <=> obj_.value : nil
      else
        nil
      end
    end


    # Returns the name.
    def to_s
      @name
    end


    def inspect  # :nodoc:
      "#<#{self.class}:0x#{object_id.to_s(16)} name=#{@name.inspect} value=#{@value}>"
    end


    include ::Comparable


  end


  # A level group is a group of related levels that can be ordered and used
  # in a log. A given log is always associated with exactly one group, which
  # controls what levels are available for log entries.
  #
  # Normally, you will use Sawmill::STANDARD_LEVELS, which defines levels
  # corresponding to the ones available in the classic ruby logger class.
  # However, this class is available to define custom level hierarchies.

  class LevelGroup


    # Create a level group.
    # You must provide a block that calls methods of
    # Sawmill::LevelGroup::Builder to define the levels in the group.

    def initialize(&block_)
      @level_order = []
      @level_names = {}
      @level_methods = {}
      @default = nil
      ::Blockenspiel.invoke(block_, Builder.new(self))
    end


    def inspect  # :nodoc:
      "#<#{self.class}:0x#{object_id.to_s(16)} levels=[#{@level_order.map{|lvl_| lvl_.name.inspect}.join(',')}]>"
    end


    # Return the default level, the one used when no level is specified.

    def default
      @default ||= highest
    end


    # Return the lowest level in the group.

    def lowest
      @level_order.first
    end


    # Return the highest level in the group.

    def highest
      @level_order.last
    end


    # Return the length of the longest name in the group.

    def column_width
      @level_order.inject(0) do |width_, level_|
        w_ = level_.name.size
        w_ > width_ ? w_ : width_
      end
    end


    # Look up a level by a logger method name.

    def lookup_method(method_name_)
      @level_methods[method_name_.to_sym]
    end


    # Get a level in this group.
    #
    # You may pass either an integer value, a level name, a level object,
    # or nil. If you pass nil, the default level is returned. Otherwise,
    # the level corresponding to the given parameter is returned. If no
    # level in this group corresponds to the parameter, nil is returned.

    def get(name_)
      case name_
      when ::Integer
        @level_order[name_]
      when Level
        @level_order[name_.value] == name_ ? name_ : nil
      when ::Symbol, ::String
        @level_names[name_.to_sym]
      when nil
        default
      else
        nil
      end
    end


    def _add(name_, opts_={})  # :nodoc:
      name_ = name_.to_sym
      default_ = opts_[:default]
      methods_ = opts_[:methods] || []
      methods_ = [methods_] unless methods_.kind_of?(::Array)
      if @level_names.include?(name_)
        raise ::ArgumentError, "Name #{name_} already taken"
      end
      value_ = @level_order.size
      level_ = Level.new(self, name_, value_)
      if default_
        if @default
          raise ::ArgumentError, "A default level is already specified"
        else
          @default = level_
        end
      end
      @level_order << level_
      @level_names[name_] = level_
      methods_.each do |method_|
        method_ = method_.to_sym
        if @level_methods.include?(method_)
          raise ::ArgumentError, "Method #{method_} already taken"
        else
          @level_methods[method_] = level_
        end
      end
    end


    # You may call methods of this object in the block passed to
    # Sawmill::LevelGroup#new.

    class Builder

      include ::Blockenspiel::DSL


      def initialize(group_)  # :nodoc:
        @group = group_
      end


      # Add a level to this group. The level is assigned the next value in
      # sequence, and the given name.
      #
      # You may also provide these options:
      #
      # [<tt>:default</tt>]
      #   If set to true, this level is made the default.
      # [<tt>:methods</tt>]
      #   If set to an array of strings or methods, those method names are
      #   mapped to this level. You may then use those methods in the
      #   Sawmill::Logger class as a shortcut for creating log messages with
      #   this level.

      def add(name_, opts_={})
        @group._add(name_, opts_)
      end


    end

  end


  # A LevelGroup that corresponds to the classic ruby logger levels.

  STANDARD_LEVELS = LevelGroup.new do
    add(:DEBUG, :methods => 'debug')
    add(:INFO, :methods => 'info', :default => true)
    add(:WARN, :methods => 'warn')
    add(:ERROR, :methods => 'error')
    add(:FATAL, :methods => 'fatal')
    add(:ANY, :methods => ['any', 'unknown'])
  end


end
