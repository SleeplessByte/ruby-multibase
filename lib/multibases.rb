require 'multibases/version'

require 'multibases/registry'

require 'multibases/base_x'
require 'multibases/base2'
require 'multibases/base16'
require 'multibases/base32'
require 'multibases/base64'

module Multibases
  class Error < StandardError; end

  # https://github.com/multiformats/multibase#multibase-table-v100-rc-semver

  version '1.0.0'

  implement 'base1', '1', nil, '1'
  implement 'base2', '0', Base2, '01'
  implement 'base8', '7', BaseX, '01234567'
  implement 'base10', '9', BaseX, '0123456789'
  implement 'base16', 'f', Base16, '0123456789abcdef'
  implement 'base32', 'b', Base32, 'abcdefghijklmnopqrstuvwxyz234567'
  implement 'base32pad', 'c', Base32, 'abcdefghijklmnopqrstuvwxyz234567='
  implement 'base32hex', 'v', Base32, '0123456789abcdefghijklmnopqrstuv'
  implement 'base32hexpad', 't', Base32, '0123456789abcdefghijklmnopqrstuv='
  implement 'base32z', 'h', Base32, 'ybndrfg8ejkmcpqxot1uwisza345h769'
  implement 'base58flickr', 'Z', BaseX, '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ'
  implement 'base58btc', 'z', BaseX, '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  implement 'base64', 'm', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  implement 'base64pad', 'M', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
  implement 'base64url', 'u', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
  implement 'base64urlpad', 'U', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_='

  module_function

  def encode(code, data)
    encoded = Multibases.engine(code).encode(data)
    Multibases.prefix(code, encoded)
  end

  def decode(data)
    data = String(data)
    code, encoded = [data[0], data[1..-1]]
    Multibases.engine(code).decode(encoded)
  end

  def engine(lookup)
    registration = fetch(lookup) { find(lookup) }
    registration[:engine]
  end

  def prefix(code, encoded)
    # Interpret as UTF-8
    return [code.ord].concat(encoded) if encoded.is_a?(Array)

    code.encode(encoded.encoding) + encoded
  end
end

module Kernel
  def Multibase(code, encoded)
    Multibases.prefix(code, encoded)
  end
end