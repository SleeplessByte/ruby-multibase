# frozen_string_literal: true

module Multibases
  class ByteArray < DelegateClass(Array)
    def hash
      __getobj__.hash
    end

    def eql?(other)
      other.to_s.eql?(to_s)
    end

    def to_arr
      __getobj__.dup
    end

    def is_a?(klazz)
      super || __getobj__.is_a?(klazz)
    end

    def transcode(from, to)
      from = from.each_with_index.to_h
      to = Hash[to.each_with_index.to_a.collect(&:reverse)]

      self.class.new(map { |byte| to[from[byte]] })
    end

    alias to_a to_arr
    alias kind_of? is_a?
  end

  class EncodedByteArray < ByteArray
    def inspect
      "[Multibases::EncodedByteArray \"#{to_str}\"]"
    end

    def to_str
      map(&:chr).join.encode(Encoding::ASCII_8BIT)
    end

    def chomp!(ord)
      return self unless ord

      __getobj__.reverse!
      index = __getobj__.find_index { |el| el != ord }
      __getobj__.slice!(0, index) unless index.nil?
      __getobj__.reverse!

      self
    end

    alias to_s to_str
  end

  class DecodedByteArray < ByteArray
    def inspect
      "[Multibases::DecodedByteArray \"#{to_str}\"]"
    end

    def to_str(encoding = Encoding::UTF_8)
      map(&:chr).join.force_encoding(encoding)
    end

    alias to_s to_str
  end

  EncodedByteArray.const_set(:EMPTY, EncodedByteArray.new([]))
  DecodedByteArray.const_set(:EMPTY, DecodedByteArray.new([]))
end
