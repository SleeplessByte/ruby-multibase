# frozen_string_literal: true

require 'multibases/error'

module Multibases
  class OrdTable
    def initialize(ords, strict:, padder: nil, encoding: nil)
      ords = ords.uniq

      @ords = ords
      @base = ords.length
      @padder = padder

      calculate_strictness(strict: strict)
      calculate_encoding(encoding: encoding)
    end

    def eql?(other)
      other.is_a?(OrdTable) &&
        other.alphabet == alphabet &&
        other.strict? == strict?
    end

    alias == eql?

    def hash
      @ords.hash
    end

    def strict?
      @strict
    end

    def tr_ords(force_strict: false)
      return @ords + [@padder].compact if strict? || force_strict

      @loose_ords + [@padder].compact
    end

    def alphabet
      @ords.pack('C*')
    end

    attr_reader :base, :factor, :padder, :encoding

    private

    def calculate_strictness(strict:)
      chars = alphabet.chars
      chars_downcased = chars.map(&:downcase).uniq
      chars_upcased = chars.map(&:upcase).uniq
      chars_cased = chars_upcased - chars_downcased

      # Strict means that the algorithm may _not_ treat incorrectly cased
      # input the same as correctly cased input. In other words, the table is
      # strict if a character exists that is both upcased and downcased and
      # therefore has a canonical casing.
      @strict = strict ||
                chars_cased.empty? ||
                chars.length != chars_downcased.length

      @loose_ords = (chars + chars_downcased + chars_upcased).uniq.map(&:ord)
    end

    def calculate_encoding(encoding:)
      invalid_ord = @ords.find { |ord| ord > 255 }
      raise AlphabetOutOfBoundary, invalid_ord if invalid_ord

      if encoding
        raise AlphabetEncodingInvalid, encoding unless valid_encoding?(encoding)

        @encoding = encoding
        return
      end

      @encoding = fits_seven_bits? ? Encoding::US_ASCII : Encoding::ASCII_8BIT
    end

    def valid_encoding?(encoding)
      ords = strict? ? @ords : @loose_ords
      ords.pack('C*').force_encoding(encoding).valid_encoding?
    end

    def fits_seven_bits?
      valid_encoding?(Encoding::US_ASCII)
    end
  end

  class IndexedOrdTable < OrdTable
    def initialize(ords, **opts)
      super(ords, **opts)

      @forward = ords.each_with_index.to_h
      @backward = Hash[@forward.to_a.collect(&:reverse)]
      @factor = Math.log(256) / Math.log(base)
    end

    def zero
      @backward[0]
    end

    def index(byte)
      @forward[byte] || !strict? && (
        @forward[byte.chr.upcase.ord] ||
        @forward[byte.chr.downcase.ord]
      )
    end

    def ord_at(index)
      @backward[index]
    end

    def encoded_length(plain_codepoints)
      (plain_codepoints.length.to_f * factor).ceil
    end

    def decoded_length(encoded_codepoints)
      (encoded_codepoints.length / factor).round
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
  end
end
