require_relative './tr_escape'

module Multibases
  class BaseX
    using TrEscape

    class Table
      def self.from(alphabet)
        raise ArgumentError, 'Alphabet too long' if alphabet.length >= 255 # 256 - zero char
        alphabet = alphabet.chars if alphabet.respond_to?(:chars)
        new(alphabet)
      end

      def initialize(chars)
        @chars = chars
        @base = chars.length
        @forward = chars.each_with_index.to_h
        @backward = Hash[@forward.to_a.collect(&:reverse)]
        @factor = Math.log(256) / Math.log(base)
        @unit_size = @factor.ceil
      end

      def index(byte)
        @forward[byte.chr]
      end

      def chr(index)
        @backward[index]
      end

      def zero
        @backward[0]
      end

      def eql?(other)
        other.is_a?(Table) && other.chars === chars
      end

      def hash
        chars.hash
      end

      def encoded_length(plain_bytes)
        (plain_bytes.length.to_f * factor).ceil
      end

      def decoded_length(encoded_bytes)
        (encoded_bytes.length / factor).ceil
      end

      attr_reader :chars, :base, :factor, :unit_size
    end

    def initialize(alphabet)
      @table = Table.from(alphabet)
    end

    def encode(plain)
      return @table.zero if plain.empty?
      plain = plain.bytes unless plain.is_a?(Array)

      zeroes_count = [0, plain.find_index { |b| b != 0 } || plain.length].max
      plain = plain.drop(zeroes_count)

      size = @table.encoded_length(plain) + zeroes_count
      result = Array.new(size, 0)
      last_position = 0

      # Transfer bytes in correct base to result
      plain.each do |byte|
        processed = 0
        result_index = size - 1

        # result[i] = result[i] * 256 + next character value
        while((byte != 0 || processed < last_position) && result_index != -1) do
          byte += (256 * result[result_index]) >> 0
          result[result_index] = (byte % @table.base) >> 0
          byte = (byte / @table.base) >> 0

          result_index -= 1
          processed += 1
        end

        last_position = processed
      end

      (@table.zero * zeroes_count) + result.drop_while(&:zero?).map { |i| @table.chr(i) }.join
    end

    def decode(encoded)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)
      return '' if encoded.empty?
      encoded = encoded.bytes unless encoded.is_a?(Array)
      zeroes_count = [0, encoded.find_index { |b| b != @table.zero } || encoded.length].max
      encoded = encoded.drop(zeroes_count)

      size = @table.decoded_length(encoded) + zeroes_count
      result = Array.new(size, 0)
      last_position = 0

      encoded.each do |encoded_byte|
        value = @table.index(encoded_byte)

        break if value == 255

        processed = 0
        result_index = size - 1

        while((value != 0 || processed < last_position) && result_index != -1) do
          value += (@table.base * result[result_index]) >> 0
          result[result_index] = (value % 256) >> 0
          value = (value / 256) >> 0

          result_index -= 1
          processed += 1
        end

        last_position = processed
      end

      p "decode #{encoded_bytes} -> #{result}"

      ("\x00" * zeroes_count) + result.drop_while(&:zero?).map(&:chr).join
    end

    def decodable?(encoded)
      encoded.tr(table_str.tr_escape, '*') =~ /\A\**\z/
    end

    def table_str
      @table.chars.join
    end
  end
end

