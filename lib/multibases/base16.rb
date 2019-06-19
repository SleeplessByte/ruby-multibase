# frozen_string_literal: true

require_relative './tr_escape'

module Multibases
  class Base16
    using TrEscape

    # RFC 4648 implementation
    def self.encode(plain)
      plain = plain.encode('UTF-8').map(&:chr) if plain.is_a?(Array)
      # plain.each_byte.map do |byte| byte.to_s(16) end.join
      plain.unpack1('H*').encode('ASCII-8BIT')
    end

    def self.decode(packed)
      # packed.scan(/../).map { |x| x.hex.chr }.join
      Array(packed).pack('H*').encode('UTF-8')
    end

    class Table
      def self.from(alphabet, **opts)
        alphabet = alphabet.chars if alphabet.respond_to?(:chars)
        new(alphabet, **opts)
      end

      def initialize(chars, strict: false)
        if chars.length < 16 || chars.length > 17
          # Allow 17 for stale padding that does nothing
          raise ArgumentError,
                'Expected chars to contain 16 exactly. Actual: ' +
                "#{chars.length} characters."
        end

        @strict = strict || chars.uniq.length != chars.map(&:downcase).uniq.length
        @chars = chars
      end

      def eql?(other)
        other.is_a?(Table) && other.chars == chars
      end

      def hash
        chars.hash
      end

      def strict?
        @strict
      end

      attr_reader :chars
    end

    def initialize(alphabet, strict: false)
      @table = Table.from(alphabet, strict: strict)
    end

    def encode(plain)
      encoded = Multibases::Base16.encode(plain)
      return encoded if default?

      encoded.tr(Default.table_str.tr_escape, table_str.tr_escape)
    end

    def decode(encoded)
      raise ArgumentError, "'#{encoded}' contains unknown characters'" unless decodable?(encoded)

      unless default?
        encoded = encoded.tr(table_str.tr_escape, Default.table_str(override_strict: @table.strict?).tr_escape)
      end

      Multibases::Base16.decode(encoded)
    end

    def default?
      @table == Default
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

    Default = Base16.new('0123456789abcdef')
  end
end
