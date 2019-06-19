# frozen_string_literal: true

require_relative './tr_escape'

module Multibases
  class BaseX
    using TrEscape

    def inspect
      "[Multibases::Base#{@table.base} alphabet=\"#{@table.chars.join}\"#{@table.strict? ? ' strict' : ''}]"
    end

    class Table
      def self.from(alphabet)
        raise ArgumentError, 'Alphabet too long' if alphabet.length >= 255 # 256 - zero char

        alphabet = alphabet.chars if alphabet.respond_to?(:chars)
        new(alphabet)
      end

      def initialize(chars, strict: false)
        chars = chars.uniq

        @chars = chars
        @base = chars.length
        @forward = chars.each_with_index.to_h
        @backward = Hash[@forward.to_a.collect(&:reverse)]
        @factor = Math.log(256) / Math.log(base)
        @unit_size = @factor.ceil

        chars_downcased = chars.map(&:downcase).uniq
        downcased = chars.map(&:upcase).uniq - chars_downcased

        # Strict means that the algorithm may _not_ treat incorrectly cased
        # input the same as correctly cased input. In other words, the table is
        # strict if a character exists that is both upcased and downcased and
        # therefore has a canonical casing.
        @strict = strict || downcased.empty? || chars.length != chars_downcased.length
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
        (encoded_bytes.length / factor).round
      end

      def encoded_zeroes_length(count)
        # For power of 2 bases, add "canonical-width"
        return (factor * count).floor if pad_to_power?
        # For other bases, add a equivalent count to front
        count
      end

      def decoded_zeroes_length(count)
        # For power of 2 bases, add "canonical-width"
        return (count / factor).round if pad_to_power?
        # For other bases, add a equivalent count to front
        count
      end

      def pad_to_power?
        (Math.log2(base) % 1).zero?
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
      return '' if plain.empty?
      plain = plain.bytes unless plain.is_a?(Array)
      expected_length = @table.encoded_length(plain)

      # Find leading zeroes
      zeroes_count = [0, plain.find_index { |b| b != 0 } || plain.length].max
      plain = plain.drop(zeroes_count)
      expected_length = @table.encoded_length(plain) unless @table.pad_to_power?

      # Encode number into destination base as byte array
      output = []
      plain_big_number = plain.inject { |a, b| (a << 8) + b }

      while plain_big_number >= @table.base do
        mod = plain_big_number % @table.base
        output.unshift(@table.chr(mod))
        plain_big_number = (plain_big_number - mod) / @table.base
      end

      output.unshift(@table.chr(plain_big_number))

      # Prepend the leading zeroes
      @table.encoded_zeroes_length(zeroes_count).times do
        output.unshift(@table.zero)
      end

      # Padding at the front (to match expected length). Because of the
      if @table.pad_to_power?
        (expected_length - output.length).times do
          output.unshift(@table.zero)
        end
      end

      # Encode correctly
      output.join.encode('ASCII-8BIT')
    end

    def decode(encoded)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)
      return '' if encoded.empty?
      encoded = encoded.force_encoding('ASCII-8BIT').chars unless encoded.is_a?(Array)
      # expected_length = @table.decoded_length(encoded)

      # Find leading zeroes
      zeroes_count = [0, encoded.find_index { |b| b != @table.zero } || encoded.length].max
      encoded = encoded.drop(zeroes_count)
      # expected_length = @table.decoded_length(plain) unless @table.pad_to_power?

      # Decode number from encoding base to base 10
      encoded_big_number = 0

      encoded.reverse.each_with_index do |char, i|
        table_i = @table.index(char)
        encoded_big_number += @table.base ** i * table_i
      end

      # Build the output by reversing the bytes. Because the encoding is "lost"
      # the result might not be correct just yet. This is up to the caller to
      # fix. The algorithm **can not know** what the encoding was.
      output = 1.upto((Math.log2(encoded_big_number)/8).ceil).collect do
        encoded_big_number, character_byte = encoded_big_number.divmod 256
        character_byte.chr # treat each byte as a character <-- encoding unknown
      end.reverse

      # Prepend the leading zeroes
      @table.decoded_zeroes_length(zeroes_count).times do
        output.unshift("\x00")
      end

      output.join('')
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
