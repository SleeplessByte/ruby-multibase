# frozen_string_literal: true

require_relative './byte_array'
require_relative './ord_table'

module Multibases
  class Base2

    def inspect
      "[Multibases::Base2 alphabet=\"#{@table.alphabet}\"]"
    end

    def self.encode(plain)
      plain = plain.map(&:chr).join if plain.is_a?(Array)
      EncodedByteArray.new(plain.unpack1('B*').bytes)
    end

    def self.decode(packed)
      packed = packed.map(&:chr).join if packed.is_a?(Array)
      # Pack only works on an array with a single bit string
      DecodedByteArray.new(Array(String(packed)).pack('B*').bytes)
    end

    class Table < OrdTable
      def self.from(alphabet, **opts)
        alphabet = alphabet.bytes if alphabet.respond_to?(:bytes)
        alphabet.map!(&:ord)

        new(alphabet, **opts)
      end

      def initialize(ords, **opts)
        ords = ords.uniq
        if ords.length != 2
          raise ArgumentError,
                'Expected chars to contain 2 exactly. Actual: ' \
                "#{ords.length} characters."
        end

        super ords, **opts
      end
    end

    def initialize(alphabet, strict: false)
      @table = Table.from(alphabet, strict: strict)
    end

    def encode(plain)
      encoded = Multibases::Base2.encode(plain)
      return encoded if default?

      encoded.transcode(Default.table_ords(force_strict: @table.strict?), table_ords)
    end

    def decode(encoded)
      return DecodedByteArray::EMPTY if encoded.empty?

      encoded = encoded.force_encoding(Encoding::ASCII_8BIT).bytes unless encoded.is_a?(Array)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)

      encoded = ByteArray.new(encoded).transcode(table_ords, Default.table_ords(force_strict: @table.strict?)) unless default?
      Multibases::Base2.decode(encoded)
    end

    def default?
      eql?(Default)
    end

    def eql?(other)
      other.is_a?(Base2) && other.instance_variable_get(:@table) == @table
    end

    alias == eql?

    def decodable?(encoded)
      (encoded.uniq - @table.tr_ords).length.zero?
    end

    def table_ords(force_strict: false)
      @table.tr_ords(force_strict: force_strict)
    end

    Default = Base2.new('01')
  end
end
