# frozen_string_literal: true

require 'multibases/error'

module Multibases

  class ByteArray < DelegateClass(Array)
    def initialize(array, encoding: nil)
      super array

      @encoding = encoding
    end

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

    def transcode(from, to, encoding: nil)
      from = from.each_with_index.to_h
      to = Hash[to.each_with_index.to_a.collect(&:reverse)]

      self.class.new(map { |byte| to[from[byte]] }, encoding: encoding)
    end

    alias to_a to_arr
    alias kind_of? is_a?
  end

  class EncodedByteArray < ByteArray
    def inspect
      encoding = @encoding || Encoding::BINARY
      "[Multibases::EncodedByteArray \"#{to_str(encoding)}\"]"
    end

    def to_str(encoding = @encoding)
      raise MissingEncoding unless encoding

      pack('C*').force_encoding(encoding)
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
      encoding = @encoding || Encoding::BINARY
      "[Multibases::DecodedByteArray \"#{to_str(encoding)}\"]"
    end

    def to_str(encoding = @encoding)
      raise MissingEncoding unless encoding

      pack('C*').force_encoding(encoding)
    end

    def force_encoding(*args)
      to_str(*args)
    end

    alias to_s to_str
  end

  EncodedByteArray.const_set(:EMPTY, EncodedByteArray.new([]))
  DecodedByteArray.const_set(:EMPTY, DecodedByteArray.new([]))
end
