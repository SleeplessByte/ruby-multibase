# frozen_string_literal: true

require 'multibases/version'
require 'multibases/registry'

module Multibases
  class Error < StandardError; end

  class NoEngine < Error
    def initialize(encoding)
      super(
        "There is no engine registered to encode or decode #{encoding}.\n" \
          'Either pass it as an argument, or use Multibases.implement to ' \
          'register it globally.'
      )
    end
  end

  Encoded = Struct.new(:code, :encoding, :length, :data) do
    ##
    # Packs the data and the code into an encoded string
    #
    # @return [EncodedByteArray]
    #
    def pack
      data.unshift(code.ord)
      data
    end

    ##
    # Decodes the data and returns a DecodedByteArray
    #
    # @return [DecodedByteArray]
    #
    def decode(engine = Multibases.engine(encoding))
      raise NoEngine, encoding unless engine

      engine.decode(data)
    end
  end

  class Identity
    def initialize(*_); end

    def encode(data)
      EncodedByteArray.new(data.is_a?(Array) ? data : data.bytes)
    end

    def decode(data)
      DecodedByteArray.new(data.is_a?(Array) ? data : data.bytes)
    end
  end

  implement 'identity', "\x00", Identity
  implement 'base1', '1'
  implement 'base2', '0'
  implement 'base8', '7'
  implement 'base10', '9'
  implement 'base16', 'f'
  implement 'base16upper', 'F'
  implement 'base32hex', 'v'
  implement 'base32hexupper', 'V'
  implement 'base32hexpad', 't'
  implement 'base32hexpadupper', 'T'
  implement 'base32', 'b'
  implement 'base32upper', 'B'
  implement 'base32pad', 'c'
  implement 'base32padupper', 'c'
  implement 'base32z', 'h'
  implement 'base58flickr', 'Z'
  implement 'base58btc', 'z'
  implement 'base64', 'm'
  implement 'base64pad', 'M'
  implement 'base64url', 'u'
  implement 'base64urlpad', 'U'

  module_function

  def encode(encoding, data, engine = Multibases.engine(encoding))
    raise NoEngine, encoding unless engine

    encoded_data = engine.encode(data)

    Encoded.new(
      Multibases.code(encoding),
      encoding,
      encoded_data.length,
      encoded_data
    )
  end

  def unpack(decorated)
    decorated = decorated.pack('c*') if decorated.is_a?(Array)
    code = decorated[0]
    encoded_data = decorated[1..-1]

    Encoded.new(
      code,
      Multibases.encoding(code),
      encoded_data.length,
      EncodedByteArray.new(encoded_data.bytes)
    )
  end

  def decorate(encoding, encoded = nil)
    return encoding.pack if encoding.is_a?(Encoded)

    encoded = encoded.bytes unless encoded.is_a?(Array)

    Encoded.new(
      Multibases.code(encoding),
      encoding,
      encoded.length,
      EncodedByteArray.new(encoded)
    ).pack
  end

  def pack(*args)
    encoded = Multibases.encode(*args)
    encoded.pack
  end

  def decode(data, *args)
    encoded = Multibases.unpack(data)
    encoded.decode(*args)
  end

  def encoding(code)
    fetch_by!(code: code).encoding
  end

  def code(encoding)
    fetch_by!(encoding: encoding).code
  end

  def engine(lookup)
    registration = find_by(code: lookup, encoding: lookup)
    raise NoEngine, lookup unless registration

    registration.engine
  end
end
