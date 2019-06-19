# frozen_string_literal: true

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

      def initialize(chars, strict: false)
        @chars = chars
        @base = chars.length
        @forward = chars.each_with_index.to_h
        @backward = Hash[@forward.to_a.collect(&:reverse)]
        @factor = Math.log(256) / Math.log(base)
        @unit_size = @factor.ceil
        @strict = strict || chars.uniq.length != chars.map(&:downcase).uniq.length
      end

      def index(byte)
        @forward[byte.chr] || !strict? && (@forward[byte.chr.upcase] || @forward[byte.chr.downcase])
      end

      def chr(index)
        @backward[index]
      end

      def zero
        @backward[0]
      end

      def eql?(other)
        other.is_a?(Table) && other.chars == chars
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

      def encoded_zeroes_length(count)
        count
      end

      def decoded_zeroes_length(count)
        (count / Math.log(@base).to_f).floor
      end

      def strict?
        @strict
      end

      attr_reader :chars, :base, :factor, :unit_size
    end

    def initialize(alphabet)
      @table = Table.from(alphabet)
    end

    def encode(plain)
      return @table.zero if plain.empty?

      plain = plain.bytes unless plain.is_a?(Array)

      # zeroes_count = [0, plain.find_index { |b| b != 0 } || plain.length].max
      # plain = plain.drop(zeroes_count)
      # zeroes_count = @table.encoded_zeroes_length(zeroes_count)

      size = @table.encoded_length(plain) # + zeroes_count
      result = Array.new(size, -1)
      last_position = 0

      # Transfer bytes in correct base to result
      plain.each do |byte|
        processed = 0
        result_index = size - 1

        # result[i] = result[i] * 256 + next character value
        while processed < last_position && result_index != -1 do
          byte += (256 * [0, result[result_index]].max)
          result[result_index] = (byte % @table.base)
          byte = (byte / @table.base)

          result_index -= 1
          processed += 1

          break if byte == 0 && processed > last_position
        end

        last_position = processed
      end

      zeroes_count = 0
      output = (@table.zero * zeroes_count) + result.drop_while(&:negative?).map { |i| @table.chr(i) }.join
      output.encode('ASCII-8BIT')
    end

    def decode(encoded)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)
      return '' if encoded.empty?

      encoded = encoded.bytes unless encoded.is_a?(Array)
      # zeroes_count = [0, encoded.find_index { |b| b.chr != @table.zero } || encoded.length].max
      # p "index: #{zeroes_count}"
      # encoded = encoded.drop(zeroes_count)
      # zeroes_count = @table.decoded_zeroes_length(zeroes_count)

      # p "count: #{zeroes_count}"

      size = @table.decoded_length(encoded) # + zeroes_count
      result = Array.new(size, -1)
      last_position = 0

      encoded.each do |encoded_byte|
        value = @table.index(encoded_byte)

        break if value == 255

        processed = 0
        result_index = size - 1

        while ((value != 0 || processed < last_position) && result_index != -1) do
          value += (@table.base * [0, result[result_index]].max) >> 0
          result[result_index] = (value % 256) >> 0
          value = (value / 256) >> 0

          result_index -= 1
          processed += 1
        end

        last_position = processed
      end

      zeroes_count = 0
      ("\x00" * zeroes_count) + result.drop_while(&:negative?).map(&:chr).join.tap do |x| puts x end
    end

    def decodable?(encoded)
      encoded.tr(table_str.tr_escape, '*') =~ /\A\**\z/
    end

    def decodable?(encoded)
      return encoded.tr(table_str.tr_escape, '*') =~ /\A\**\z/ if @table.strict?

      encoded.downcase.tr(table_str(override_strict: false).tr_escape, '*') =~ /\A\**\z/
    end

    def table_str(override_strict: nil)
      return @table.chars.join if @table.strict? || override_strict == true

      @loose_table_str ||= @table.chars.join +
        (@table.chars.map(&:upcase) + @table.chars.map(&:downcase) - @table.chars).join
    end
  end
end
