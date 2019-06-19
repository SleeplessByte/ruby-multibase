# frozen_string_literal: true

require_relative './tr_escape'

module Multibases
  class Base64
    using TrEscape

    def inspect
      '[Multibases::Base64 ' \
        "alphabet=\"#{@table.alphabet}\"" \
        "#{@table.padder.nil? ? '' : ' pad="' + @table.padder.chr + '"'}" \
      ']'
    end

    # RFC 4648 implementation
    def self.encode(plain)
      plain = plain.map(&:chr).join if plain.is_a?(Array)

      # Base64.strict_encode(plain)
      EncodedByteArray.new(Array(String(plain)).pack('m0').bytes)
    end

    def self.decode(packed)
      packed = packed.map(&:chr).join if packed.is_a?(Array)
      # Base64.strict_decode64("m").first
      # Don't use m0, as that requires padderding _always_
      DecodedByteArray.new(packed.unpack1('m').bytes)
    end

    class Table < OrdTable
      def self.from(alphabet, **opts)
        alphabet = alphabet.bytes if alphabet.respond_to?(:bytes)
        alphabet.map!(&:ord)

        new(alphabet, **opts)
      end

      def initialize(ords, **opts)
        ords = ords.uniq

        if ords.length < 64 || ords.length > 65
          raise ArgumentError,
                'Expected alphabet to contain 64 characters or 65 + 1 ' \
                "padding character. Actual: #{ords.length} characters"
        end

        padder = nil
        *ords, padder = ords if ords.length == 65

        super(ords, padder: padder, **opts)
      end
    end

    def initialize(alphabet, strict: false)
      @table = Table.from(alphabet, strict: strict)
    end

    def encode(plain)
      return EncodedByteArray::EMPTY if plain.empty?

      encoded = Multibases::Base64.encode(plain)
      encoded.chomp!(Default.table_padder) unless @table.padder
      return encoded if default?

      encoded.transcode(Default.table_ords(force_strict: @table.strict?), table_ords)
    end

    def decode(encoded)
      return DecodedByteArray::EMPTY if encoded.empty?

      encoded = encoded.force_encoding(Encoding::ASCII_8BIT).bytes unless encoded.is_a?(Array)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)

      encoded = ByteArray.new(encoded).transcode(table_ords, Default.table_ords(force_strict: @table.strict?)) unless default?
      Multibases::Base64.decode(encoded)
    end

    def default?
      eql?(Default)
    end

    def eql?(other)
      other.is_a?(Base64) && other.instance_variable_get(:@table) == @table
    end

    alias == eql?

    def decodable?(encoded)
      (encoded.uniq - table_ords).length.zero?
    end

    def table_ords(force_strict: nil)
      @table.tr_ords(force_strict: force_strict)
    end

    def table_padder
      @table.padder
    end

    Default = Base64.new('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=')
    UrlSafe = Base64.new('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=')
  end
end
