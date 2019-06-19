# frozen_string_literal: true

module Chunkify
  refine String do
    def chunks(size, table)
      bytes.each_slice(size).map do |slice|
        ::Multibases::Base32::Chunk.new(slice, table)
      end
    end
  end
end

module Multibases
  # RFC 3548
  class Base32
    using Chunkify

    def self.encode(plain)
      Default.encode(plain)
    end

    def self.decode(plain)
      Default.decode(plain)
    end

    class Table
      def self.from(alphabet)
        alphabet = alphabet.chars if alphabet.respond_to?(:chars)
        new(alphabet)
      end

      attr_reader :chars

      def initialize(chars, strict: false)
        if chars.length < 32 || chars.length > 33
          raise ArgumentError,
                'Expected chars to contain 32 characters or 32 + 1 padding ' +
                "character. Actual: #{chars.length} characters"
        end

        @strict = strict || chars.uniq.length != chars.map(&:downcase).uniq.length
        @chars = chars
        @forward = chars.each_with_index.to_h
        @backward = Hash[@forward.to_a.collect(&:reverse)]
      end

      def index(byte)
        @forward[byte.chr] || !strict? && (@forward[byte.chr.upcase] || @forward[byte.chr.downcase])
      end

      def chr(index)
        @backward[index & 0x1f]
      end

      def pad
        @backward[32]
      end

      def eql?(other)
        other.is_a?(Table) && other.chars == chars
      end

      def hash
        chars.hash
      end

      def strict?
        @strict
      end
    end

    class Chunk
      def initialize(bytes, table)
        @bytes = bytes
        @table = table
      end

      def decode
        bytes = @bytes.take_while { |c| c.chr != @table.pad }

        n = (bytes.length * 5.0 / 8.0).floor
        p = bytes.length < 8 ? 5 - (n * 8) % 5 : 0

        c = bytes.inject(0) do |m, o|
          i = @table.index(o)
          raise ArgumentError, "Invalid character '#{o.chr}'" if i.nil?

          (m << 5) + i
        end >> p

        (0..(n - 1)).to_a.reverse.collect { |i| ((c >> i * 8) & 0xff).chr }.join
      end

      def encode
        n = (@bytes.length * 8.0 / 5.0).ceil
        p = n < 8 ? 5 - (@bytes.length * 8) % 5 : 0
        c = @bytes.inject(0) { |m, o| (m << 8) + o } << p

        output = (0..(n - 1)).to_a.reverse.collect { |i| @table.chr(c >> i * 5) }.join
        @table.pad ? output + @table.pad * (8 - n) : output
      end
    end

    def initialize(alphabet)
      @table = Table.from(alphabet)
    end

    def encode(plain)
      plain = plain.map(&:chr) if plain.is_a?(Array)
      plain.chunks(5, @table).collect(&:encode).join.encode('ASCII-8BIT')
    end

    def decode(encoded)
      encoded = encoded.map(&:chr) if encoded.is_a?(Array)
      encoded.chunks(8, @table).collect(&:decode).join
    end

    Default = Base32.new('abcdefghijklmnopqrstuvwxyz234567=')
  end
end
