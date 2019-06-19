# frozen_string_literal: true

require_relative './tr_escape'

module Multibases
  class Base64
    using TrEscape

    # RFC 4648 implementation
    def self.encode(plain)
      # Base64.strict_encode(plain)
      Array(plain).pack('m0').encode('ASCII-8BIT')
    end

    def self.decode(packed)
      packed = packed.map(&:chr) if packed.is_a?(Array)
      # Base64.strict_decode64("m").first
      # Don't use m0, as that requires padding _always_
      packed.unpack1('m')
    end

    class Table
      def self.from(string)
        new(string.chars)
      end

      attr_reader :chars

      def initialize(chars)
        if chars.length < 64 || chars.length > 65
          raise ArgumentError,
                'Expected chars to contain 64 characters or 64 + 1 padding ' +
                "character. Actual: #{chars.length} characters"
        end

        @chars = chars
      end

      def eql?(other)
        other.is_a?(Table) && other.chars == chars
      end

      def hash
        chars.hash
      end

      def pad
        @chars[64]
      end
    end

    def initialize(table)
      @table = table.is_a?(String) ? Table.from(table) : Table.new(table)
    end

    def encode(plain)
      encoded = Multibases::Base64.encode(plain)
      encoded = encoded.sub(/=+\Z/, '') unless @table.pad
      return encoded if default?

      encoded.tr(Default.table_str.tr_escape, table_str.tr_escape)
    end

    def decode(encoded)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)

      encoded = encoded.tr(table_str.tr_escape, Default.table_str.tr_escape) unless default?
      Multibases::Base64.decode(encoded)
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

    Default = Base64.new('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=')
    UrlSafe = Base64.new('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=')
  end
end
