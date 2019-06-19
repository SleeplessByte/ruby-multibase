# frozen_string_literal: true

require_relative './byte_array'
require_relative './ord_table'

module Multibases
  class BaseX

    def inspect
      "[Multibases::Base#{@table.base} alphabet=\"#{@table.alphabet}\"#{@table.strict? ? ' strict' : ''}]"
    end

    class Table < IndexedOrdTable
      def self.from(alphabet, **opts)
        raise ArgumentError, 'Alphabet too long' if alphabet.length >= 255 # 256 - zero char

        alphabet = alphabet.bytes if alphabet.respond_to?(:bytes)
        alphabet.map!(&:ord)

        new(alphabet, **opts)
      end
    end

    def initialize(alphabet, strict: false)
      @table = Table.from(alphabet, strict: strict)
    end

    ##
    # Encode +plain+ to an encoded string
    #
    # @param plain [String, Array] plain string or byte array
    # @return [EncodedByteArray] encoded byte array
    #
    def encode(plain)
      return EncodedByteArray::EMPTY if plain.empty?

      plain = plain.bytes unless plain.is_a?(Array)
      expected_length = @table.encoded_length(plain)

      # Find leading zeroes
      zeroes_count = [0, plain.find_index { |b| b.ord != 0 } || plain.length].max
      plain = plain.drop(zeroes_count)
      expected_length = @table.encoded_length(plain) unless @table.pad_to_power?

      # Encode number into destination base as byte array
      output = []
      plain_big_number = plain.inject { |a, b| (a << 8) + b.ord }

      while plain_big_number >= @table.base
        mod = plain_big_number % @table.base
        output.unshift(@table.ord_at(mod))
        plain_big_number = (plain_big_number - mod) / @table.base
      end

      output.unshift(@table.ord_at(plain_big_number))

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

      EncodedByteArray.new(output)
    end

    ##
    # Decode +encoded+ to a byte array
    #
    # @param encoded [String, Array, EncodedByteArray] encoded string or byte array
    # @return [DecodedByteArray] decoded byte array
    #
    def decode(encoded)
      return DecodedByteArray::EMPTY if encoded.empty?

      encoded = encoded.force_encoding(Encoding::ASCII_8BIT).bytes unless encoded.is_a?(Array)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)

      # Find leading zeroes
      zeroes_count = [0, encoded.find_index { |b| b.ord != @table.zero } || encoded.length].max
      encoded = encoded.drop(zeroes_count)

      # Decode number from encoding base to base 10
      encoded_big_number = 0

      encoded.reverse.each_with_index do |char, i|
        table_i = @table.index(char)
        encoded_big_number += @table.base**i * table_i
      end

      # Build the output by reversing the bytes. Because the encoding is "lost"
      # the result might not be correct just yet. This is up to the caller to
      # fix. The algorithm **can not know** what the encoding was.
      output = 1.upto((Math.log2(encoded_big_number) / 8).ceil).collect do
        encoded_big_number, character_byte = encoded_big_number.divmod 256
        character_byte
      end.reverse

      # Prepend the leading zeroes
      @table.decoded_zeroes_length(zeroes_count).times do
        output.unshift(0x00)
      end

      DecodedByteArray.new(output)
    end

    def decodable?(encoded)
      (encoded.uniq - @table.tr_ords).length.zero?
    end
  end
end
