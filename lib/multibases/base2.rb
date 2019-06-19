# frozen_string_literal: true

require_relative './tr_escape'

module Multibases
  class Base2
    using TrEscape

    def inspect
      "[Multibases::Base2 alphabet=\"#{@table.chars.join}\"]"
    end

    def self.encode(plain)
      plain = plain.map(&:chr) if plain.is_a?(Array)
      plain.unpack1('B*').encode('ASCII-8BIT')
    end

    def self.decode(packed)
      Array(packed).pack('B*')
    end

    class Table
      def self.from(alphabet)
        alphabet = alphabet.chars if alphabet.respond_to?(:chars)
        new(alphabet)
      end

      def initialize(chars)
        chars = chars.uniq

        if chars.length < 2 || chars.length > 2
          # Allow 17 for stale padding that does nothing
          raise ArgumentError,
                'Expected chars to contain 2 exactly. Actual: ' +
                "#{chars.length} characters."
        end

        @chars = chars
      end

      def eql?(other)
        other.is_a?(Table) && other.chars == chars
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
      encoded = Multibases::Base2.encode(plain)
      return encoded if default?

      encoded.tr(Default.table_str.tr_escape, table_str.tr_escape)
    end

    def decode(encoded)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)

      encoded = encoded.tr(table_str.tr_escape, Default.table_str.tr_escape) unless default?
      Multibases::Base2.decode(encoded)
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

    Default = Base2.new('01')
  end
end
