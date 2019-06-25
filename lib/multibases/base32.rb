# frozen_string_literal: true

require 'multibases/byte_array'
require 'multibases/ord_table'

module Multibases
  # RFC 3548
  class Base32
    def inspect
      '[Multibases::Base32 ' \
        "alphabet=\"#{@table.chars.join}\"" \
        "#{@table.strict? ? ' strict' : ''}" \
      ']'
    end

    def self.encode(plain)
      Default.encode(plain)
    end

    def self.decode(plain)
      Default.decode(plain)
    end

    class Table < IndexedOrdTable
      def self.from(alphabet, **opts)
        alphabet = alphabet.bytes if alphabet.respond_to?(:bytes)
        alphabet.map!(&:ord)

        new(alphabet, **opts)
      end

      def initialize(ords, **opts)
        ords = ords.uniq

        if ords.length < 32 || ords.length > 33
          raise ArgumentError,
                'Expected alphabet to contain 32 characters or 32 + 1 ' \
                "padding character. Actual: #{ords.length} characters"
        end

        padder = nil
        *ords, padder = ords if ords.length == 33

        super(ords, padder: padder, **opts)
      end
    end

    class Chunk
      def initialize(bytes, table)
        @bytes = bytes
        @table = table
      end

      def decode
        bytes = @bytes.take_while { |c| c != @table.padder }

        n = (bytes.length * 5.0 / 8.0).floor
        p = bytes.length < 8 ? 5 - (n * 8) % 5 : 0

        c = bytes.inject(0) do |m, o|
          i = @table.index(o)
          raise ArgumentError, "Invalid character '#{[o].pack('C*')}'" if i.nil?

          (m << 5) + i
        end >> p

        (0..(n - 1)).to_a.reverse.collect { |i| ((c >> i * 8) & 0xff) }
      end

      def encode
        n = (@bytes.length * 8.0 / 5.0).ceil
        p = n < 8 ? 5 - (@bytes.length * 8) % 5 : 0
        c = @bytes.inject(0) { |m, o| (m << 8) + o } << p

        output = (0..(n - 1)).to_a.reverse.collect do |i|
          @table.ord_at((c >> i * 5) & 0x1f)
        end
        @table.padder ? output + Array.new((8 - n), @table.padder) : output
      end
    end

    def initialize(alphabet, strict: false, encoding: nil)
      @table = Table.from(alphabet, strict: strict, encoding: encoding)
    end

    def encode(plain)
      return EncodedByteArray::EMPTY if plain.empty?

      EncodedByteArray.new(
        chunks(plain, 5).collect(&:encode).flatten,
        encoding: @table.encoding
      )
    end

    def decode(encoded)
      return DecodedByteArray::EMPTY if encoded.empty?

      DecodedByteArray.new(chunks(encoded, 8).collect(&:decode).flatten)
    end

    private

    def chunks(whole, size)
      whole = whole.bytes unless whole.is_a?(Array)

      whole.each_slice(size).map do |slice|
        ::Multibases::Base32::Chunk.new(slice, @table)
      end
    end

    Default = Base32.new('abcdefghijklmnopqrstuvwxyz234567=')
  end
end
