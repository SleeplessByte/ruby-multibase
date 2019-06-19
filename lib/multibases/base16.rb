# frozen_string_literal: true

require_relative './byte_array'
require_relative './ord_table'

module Multibases
  class Base16

    def inspect
      "[Multibases::Base16 alphabet=\"#{@table.alphabet}\"#{@table.strict? ? ' strict' : ''}]"
    end

    # RFC 4648 implementation
    def self.encode(plain)
      plain = plain.map(&:chr).join if plain.is_a?(Array)

      # plain.each_byte.map do |byte| byte.to_s(16) end.join
      EncodedByteArray.new(plain.unpack1('H*').bytes)
    end

    def self.decode(packed)
      packed = packed.map(&:chr).join if packed.is_a?(Array)

      # packed.scan(/../).map { |x| x.hex.chr }.join
      DecodedByteArray.new(Array(String(packed)).pack('H*').bytes)
    end

    class Table < OrdTable
      def self.from(alphabet, **opts)
        alphabet = alphabet.bytes if alphabet.respond_to?(:bytes)
        alphabet.map!(&:ord)

        new(alphabet, **opts)
      end

      def initialize(ords, **opts)
        ords = ords.uniq
        if ords.length < 16 || ords.length > 17
          # Allow 17 for stale padding that does nothing
          raise ArgumentError,
                'Expected alphabet to contain 16 exactly. Actual: ' \
                "#{ords.length} characters."
        end

        super ords, **opts
      end
    end

    def initialize(alphabet, strict: false)
      @table = Table.from(alphabet, strict: strict)
    end

    def encode(plain)
      encoded = Multibases::Base16.encode(plain)
      return encoded if default?

      encoded.transcode(Default.table_ords(force_strict: @table.strict?), table_ords)
    end

    def decode(encoded)
      return DecodedByteArray::EMPTY if encoded.empty?

      encoded = encoded.force_encoding(Encoding::ASCII_8BIT).bytes unless encoded.is_a?(Array)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)

      encoded = ByteArray.new(encoded).transcode(table_ords, Default.table_ords(force_strict: @table.strict?)) unless default?
      Multibases::Base16.decode(encoded)
    end

    def default?
      eql?(Default)
    end

    def eql?(other)
      other.is_a?(Base16) && other.instance_variable_get(:@table) == @table
    end

    alias == eql?

    def decodable?(encoded)
      (encoded.uniq - @table.tr_ords).length.zero?
    end

    def table_ords(force_strict: nil)
      @table.tr_ords(force_strict: force_strict)
    end

    Default = Base16.new('0123456789abcdef')
  end
end
