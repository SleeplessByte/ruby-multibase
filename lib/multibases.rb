# frozen_string_literal: true

require 'multibases/bare'

require 'multibases/registry'

require 'multibases/base_x'
require 'multibases/base2'
require 'multibases/base16'
require 'multibases/base32'
require 'multibases/base64'

module Multibases
  # https://github.com/multiformats/multibase#multibase-table-v100-rc-semver
  multibase_version '1.0.0'

  # rubocop:disable Metrics/LineLength
  implement 'base1', '1', nil, '1'
  implement 'base2', '0', Base2, '01'
  implement 'base8', '7', BaseX, '01234567'
  implement 'base10', '9', BaseX, '0123456789'
  implement 'base16', 'f', Base16, '0123456789abcdef'
  implement 'base16upper', 'F', Base16, '0123456789ABCDEF'
  implement 'base32', 'b', Base32, 'abcdefghijklmnopqrstuvwxyz234567'
  implement 'base32upper', 'B', Base32, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'
  implement 'base32pad', 'c', Base32, 'abcdefghijklmnopqrstuvwxyz234567='
  implement 'base32padupper', 'C', Base32, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567='
  implement 'base32hex', 'v', Base32, '0123456789abcdefghijklmnopqrstuv'
  implement 'base32hexupper', 'V', Base32, '0123456789ABCDEFGHIJKLMNOPQRSTUV'
  implement 'base32hexpad', 't', Base32, '0123456789abcdefghijklmnopqrstuv='
  implement 'base32hexpadupper', 'T', Base32, '0123456789ABCDEFGHIJKLMNOPQRSTUV='
  implement 'base32z', 'h', Base32, 'ybndrfg8ejkmcpqxot1uwisza345h769'
  implement 'base58flickr', 'Z', BaseX, '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ'
  implement 'base58btc', 'z', BaseX, '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  implement 'base64', 'm', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  implement 'base64pad', 'M', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
  implement 'base64url', 'u', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
  implement 'base64urlpad', 'U', Base64, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_='
  # rubocop:enable Metrics/LineLength
end
