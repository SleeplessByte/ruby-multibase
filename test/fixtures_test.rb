# frozen_string_literal: true

require 'test_helper'

require 'csv'

# https://github.com/multiformats/multibase/blob/2d108367e5e3d30c9e3f23475420c242ff8411c8/tests/test1.csv
TEST_1 = CSV.parse(%(
encoding, Decentralize everything!!
base2, 001000100011001010110001101100101011011100111010001110010011000010110110001101001011110100110010100100000011001010111011001100101011100100111100101110100011010000110100101101110011001110010000100100001
base8, 71043126154533472162302661513646244031273145344745643206455631620441
base16, f446563656e7472616c697a652065766572797468696e672121
base16upper, F446563656E7472616C697A652065766572797468696E672121
base32, birswgzloorzgc3djpjssazlwmvzhs5dinfxgoijb
base32upper, BIRSWGZLOORZGC3DJPJSSAZLWMVZHS5DINFXGOIJB
base32hex, v8him6pbeehp62r39f9ii0pbmclp7it38d5n6e891
base32hexupper, V8HIM6PBEEHP62R39F9II0PBMCLP7IT38D5N6E891
base32pad, cirswgzloorzgc3djpjssazlwmvzhs5dinfxgoijb
base32padupper, CIRSWGZLOORZGC3DJPJSSAZLWMVZHS5DINFXGOIJB
base32hexpad, t8him6pbeehp62r39f9ii0pbmclp7it38d5n6e891
base32hexpadupper, T8HIM6PBEEHP62R39F9II0PBMCLP7IT38D5N6E891
base32z, het1sg3mqqt3gn5djxj11y3msci3817depfzgqejb
base58flickr, Ztwe7gVTeK8wswS1gf8hrgAua9fcw9reboD
base58btc, zUXE7GvtEk8XTXs1GF8HSGbVA9FCX9SEBPe
base64, mRGVjZW50cmFsaXplIGV2ZXJ5dGhpbmchIQ
base64pad, MRGVjZW50cmFsaXplIGV2ZXJ5dGhpbmchIQ==
base64url, uRGVjZW50cmFsaXplIGV2ZXJ5dGhpbmchIQ
base64urlpad, URGVjZW50cmFsaXplIGV2ZXJ5dGhpbmchIQ==
).strip, headers: true)

# https://github.com/multiformats/multibase/blob/2d108367e5e3d30c9e3f23475420c242ff8411c8/tests/test2.csv
TEST_2 = CSV.parse(%(
encoding, yes mani !
base2, 001111001011001010111001100100000011011010110000101101110011010010010000000100001
base8, 7171312714403326055632220041
base16, f796573206d616e692021
base16upper, F796573206D616E692021
base32, bpfsxgidnmfxgsibb
base32upper, BPFSXGIDNMFXGSIBB
base32hex, vf5in683dc5n6i811
base32hexupper, VF5IN683DC5N6I811
base32pad, cpfsxgidnmfxgsibb
base32padupper, CPFSXGIDNMFXGSIBB
base32hexpad, tf5in683dc5n6i811
base32hexpadupper, TF5IN683DC5N6I811
base32z, hxf1zgedpcfzg1ebb
base58flickr, Z7Pznk19XTTzBtx
base58btc, z7paNL19xttacUY
base64, meWVzIG1hbmkgIQ
base64pad, MeWVzIG1hbmkgIQ==
base64url, ueWVzIG1hbmkgIQ
base64urlpad, UeWVzIG1hbmkgIQ==
).strip, headers: true)

# https://github.com/multiformats/multibase/blob/2d108367e5e3d30c9e3f23475420c242ff8411c8/tests/test3.csv
TEST_3 = CSV.parse(%(
encoding, hello world
base2, 00110100001100101011011000110110001101111001000000111011101101111011100100110110001100100
base8, 7064145330661571007355734466144
base10, 9126207244316550804821666916
base16, f68656c6c6f20776f726c64
base16upper, F68656C6C6F20776F726C64
base32, bnbswy3dpeb3w64tmmq
base32upper, BNBSWY3DPEB3W64TMMQ
base32hex, vd1imor3f41rmusjccg
base32hexupper, VD1IMOR3F41RMUSJCCG
base32pad, cnbswy3dpeb3w64tmmq======
base32padupper, CNBSWY3DPEB3W64TMMQ======
base32hexpad, td1imor3f41rmusjccg======
base32hexpadupper, TD1IMOR3F41RMUSJCCG======
base32z, hpb1sa5dxrb5s6hucco
base58flickr, ZrTu1dk6cWsRYjYu
base58btc, zStV1DL6CwTryKyV
base64, maGVsbG8gd29ybGQ
base64pad, MaGVsbG8gd29ybGQ=
base64url, uaGVsbG8gd29ybGQ
base64urlpad, UaGVsbG8gd29ybGQ=
).strip, headers: true)

# https://github.com/multiformats/multibase/blob/2d108367e5e3d30c9e3f23475420c242ff8411c8/tests/test4.csv
TEST_4 = CSV.parse(%(
encoding, \x00yes mani !
base2, 00000000001111001011001010111001100100000011011010110000101101110011010010010000000100001
base8, 7000171312714403326055632220041
base10, 90573277761329450583662625
base16, f00796573206d616e692021
base16upper, F00796573206D616E692021
base32, bab4wk4zanvqw42jaee
base32upper, BAB4WK4ZANVQW42JAEE
base32hex, v01smasp0dlgmsq9044
base32hexupper, V01SMASP0DLGMSQ9044
base32pad, cab4wk4zanvqw42jaee======
base32padupper, CAB4WK4ZANVQW42JAEE======
base32hexpad, t01smasp0dlgmsq9044======
base32hexpadupper, T01SMASP0DLGMSQ9044======
base32z, hybhskh3ypiosh4jyrr
base58flickr, Z17Pznk19XTTzBtx
base58btc, z17paNL19xttacUY
base64, mAHllcyBtYW5pICE
base64pad, MAHllcyBtYW5pICE=
base64url, uAHllcyBtYW5pICE
base64urlpad, UAHllcyBtYW5pICE=
).strip, headers: true)

# https://github.com/multiformats/multibase/blob/2d108367e5e3d30c9e3f23475420c242ff8411c8/tests/test5.csv
TEST_5 = CSV.parse(%(
encoding, \x00\x00yes mani !
base2, 0000000000000000001111001011001010111001100100000011011010110000101101110011010010010000000100001
base8, 700000171312714403326055632220041
base16, f0000796573206d616e692021
base16upper, F0000796573206D616E692021
base32, baaahszltebwwc3tjeaqq
base32upper, BAAAHSZLTEBWWC3TJEAQQ
base32hex, v0007ipbj41mm2rj940gg
base32hexupper, V0007IPBJ41MM2RJ940GG
base32pad, caaahszltebwwc3tjeaqq====
base32padupper, CAAAHSZLTEBWWC3TJEAQQ====
base32hexpad, t0007ipbj41mm2rj940gg====
base32hexpadupper, T0007IPBJ41MM2RJ940GG====
base32z, hyyy813murbssn5ujryoo
base58flickr, Z117Pznk19XTTzBtx
base58btc, z117paNL19xttacUY
base64, mAAB5ZXMgbWFuaSAh
base64pad, MAAB5ZXMgbWFuaSAh
base64url, uAAB5ZXMgbWFuaSAh
base64urlpad, UAAB5ZXMgbWFuaSAh
).strip, headers: true)

# https://github.com/multiformats/multibase/blob/2d108367e5e3d30c9e3f23475420c242ff8411c8/tests/test6.csv
TEST_6 = CSV.parse(%(
encoding, hello world
base16, f68656c6c6f20776F726C64
base16upper, F68656c6c6f20776F726C64
base32, bnbswy3dpeB3W64TMMQ
base32upper, Bnbswy3dpeB3W64TMMQ
base32hex, vd1imor3f41RMUSJCCG
base32hexupper, Vd1imor3f41RMUSJCCG
base32pad, cnbswy3dpeB3W64TMMQ======
base32padupper, Cnbswy3dpeB3W64TMMQ======
base32hexpad, td1imor3f41RMUSJCCG======
base32hexpadupper, Td1imor3f41RMUSJCCG======
).strip, headers: true)

# Originally js-multibase/master/test/multibase.spec.js
TEST_7 = [
  ['base16', "\x01", 'f01'],
  ['base16', "\x0f", 'f0f'],
  ['base64', '÷ïÿ', 'mw7fDr8O/'],
  ['base64', '÷ïÿ🥰÷ïÿ😎🥶🤯', 'mw7fDr8O/8J+lsMO3w6/Dv/CfmI7wn6W28J+krw'],
  ['base64url', '÷ïÿ', 'uw7fDr8O_'],
  ['base64url', '÷ïÿ🥰÷ïÿ😎🥶🤯', 'uw7fDr8O_8J-lsMO3w6_Dv_CfmI7wn6W28J-krw'],
  ['base64urlpad', '÷ïÿ🥰÷ïÿ😎🥶🤯', 'Uw7fDr8O_8J-lsMO3w6_Dv_CfmI7wn6W28J-krw==']
]

TEST_8 = [
  ['base16', 'f', 'f66'],
  ['base16', 'fo', 'f666f'],
  ['base16', 'foo', 'f666f6f'],
  ['base16', 'foob', 'f666f6f62'],
  ['base16', 'fooba', 'f666f6f6261'],
  ['base16', 'foobar', 'f666f6f626172'],

  ['base32', 'f', 'bmy'],
  ['base32', 'fo', 'bmzxq'],
  ['base32', 'foo', 'bmzxw6'],
  ['base32', 'foob', 'bmzxw6yq'],
  ['base32', 'fooba', 'bmzxw6ytb'],
  ['base32', 'foobar', 'bmzxw6ytboi'],

  ['base32pad', 'f', 'cmy======'],
  ['base32pad', 'fo', 'cmzxq===='],
  ['base32pad', 'foo', 'cmzxw6==='],
  ['base32pad', 'foob', 'cmzxw6yq='],
  ['base32pad', 'fooba', 'cmzxw6ytb'],
  ['base32pad', 'foobar', 'cmzxw6ytboi======'],

  ['base32hex', 'f', 'vco'],
  ['base32hex', 'fo', 'vcpng'],
  ['base32hex', 'foo', 'vcpnmu'],
  ['base32hex', 'foob', 'vcpnmuog'],
  ['base32hex', 'fooba', 'vcpnmuoj1'],
  ['base32hex', 'foobar', 'vcpnmuoj1e8'],

  ['base32hexpad', 'f', 'tco======'],
  ['base32hexpad', 'fo', 'tcpng===='],
  ['base32hexpad', 'foo', 'tcpnmu==='],
  ['base32hexpad', 'foob', 'tcpnmuog='],
  ['base32hexpad', 'fooba', 'tcpnmuoj1'],
  ['base32hexpad', 'foobar', 'tcpnmuoj1e8======'],

  ['base64', 'f', 'mZg'],
  ['base64', 'fo', 'mZm8'],
  ['base64', 'foo', 'mZm9v'],
  ['base64', 'foob', 'mZm9vYg'],
  ['base64', 'fooba', 'mZm9vYmE'],
  ['base64', 'foobar', 'mZm9vYmFy'],

  ['base64pad', 'f', 'MZg=='],
  ['base64pad', 'fo', 'MZm8='],
  ['base64pad', 'foo', 'MZm9v'],
  ['base64pad', 'foob', 'MZm9vYg=='],
  ['base64pad', 'fooba', 'MZm9vYmE='],
  ['base64pad', 'foobar', 'MZm9vYmFy'],

  ['base64urlpad', 'f', 'UZg=='],
  ['base64urlpad', 'fo', 'UZm8='],
  ['base64urlpad', 'foo', 'UZm9v'],
  ['base64urlpad', 'foob', 'UZm9vYg=='],
  ['base64urlpad', 'fooba', 'UZm9vYmE='],
  ['base64urlpad', 'foobar', 'UZm9vYmFy']
]

class MultibasesFixturesTest < Minitest::Test
  [
    [TEST_1, 'decentralize_everthing'],
    [TEST_2, 'yes_mani'],
    [TEST_3, 'hello_world'],
    [TEST_4, 'null_yes_mani'],
    [TEST_5, 'null_null_yes_mani']
  ].each do |fixture, name|
    fixture.each do |row|
      plain_text = row.headers[1][1..-1] # remove single leading space
      packed_text = row[1][1..-1]
      encoding = row['encoding']

      define_method("test_#{encoding}_encode_on_#{name}") do
        assert_equal packed_text, Multibases.pack(encoding, plain_text)
      end

      define_method("test_#{encoding}_decode_on_#{name}") do
        assert_equal plain_text, Multibases.decode(packed_text)
      end
    end
  end

  TEST_6.each do |row|
    plain_text = row.headers[1][1..-1] # remove single leading space
    packed_text = row[1][1..-1]
    encoding = row['encoding']

    expected_packed_text = encoding.include?('upper') ?
      packed_text.upcase :
      packed_text.downcase

    define_method("test_#{encoding}_encode_hello_world_canonically") do
      assert_equal expected_packed_text, Multibases.pack(encoding, plain_text)
    end

    define_method("test_#{encoding}_decode_non_canonical_hello_world") do
      assert_equal plain_text, Multibases.decode(packed_text)
    end
  end

  TEST_7.each_with_index do |row, i|
    encoding = row[0]
    plain_text = row[1].encode(Encoding::UTF_8)
    packed_text = row[2]

    define_method("test_#{encoding}_encode_on_emojies_#{i}") do
      assert_equal packed_text, Multibases.pack(encoding, plain_text)
    end

    define_method("test_#{encoding}_decode_on_emojies_#{i}") do
      assert_equal plain_text, Multibases.decode(packed_text).force_encoding(Encoding::UTF_8)
    end
  end

  TEST_8.each do |row|
    encoding = row[0]
    plain_text = row[1]
    packed_text = row[2]

    define_method("test_#{encoding}_encode_on_#{plain_text}") do
      assert_equal packed_text, Multibases.pack(encoding, plain_text)
    end

    define_method("test_#{encoding}_decode_on_#{plain_text}") do
      assert_equal plain_text, Multibases.decode(packed_text)
    end
  end
end
