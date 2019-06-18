require_relative './tr_escape'

module Multibases
  class Base16
    using TrEscape

    # RFC 4648 implementation
    def self.encode(plain)
      plain = plain.map(&:chr) if plain.is_a?(Array)
      # plain.each_byte.map do |byte| byte.to_s(16) end.join
      plain.unpack('H*').first
    end

    def self.decode(packed)
      # packed.scan(/../).map { |x| x.hex.chr }.join
      Array(packed).pack('H*')
    end

    class Table
      def self.from(alphabet)
        alphabet = alphabet.chars if alphabet.respond_to?(:chars)
        new(alphabet)
      end

      def initialize(chars)
        if chars.length < 16 || chars.length > 17
          # Allow 17 for stale padding that does nothing
          raise ArgumentError, "Expected chars to contain 16 exactly. " +
            "Actual: #{chars.length} characters"
        end

        @chars = chars
      end

      def eql?(other)
        other.is_a?(Table) && other.chars === chars
      end

      def hash
        chars.hash
      end

      attr_reader :chars
    end

    def initialize(alphabet)
      @table = Table.from(alphabet)
    end

    def encode(plain)
      encoded = Multibases::Base16.encode(plain)
      return encoded if default?
      encoded.tr(Default.table_str.tr_escape, table_str.tr_escape)
    end

    def decode(encoded)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)
      encoded = encoded.tr(table_str.tr_escape, Default.table_str.tr_escape) unless default?
      Multibases::Base16.decode(encoded)
    end

    def default?
      @table == Default
    end

    def decodable?(encoded)
      encoded.tr(table_str.tr_escape, '*') =~ /\A\**\z/
    end

    def table_str
      @table.chars.join
    end

    Default = Base16.new('0123456789abcdef')
  end
end
