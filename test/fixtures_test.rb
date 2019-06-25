# frozen_string_literal: true

require 'test_helper'
require 'csv'

# rubocop:disable Metrics/LineLength, Style/WordArray

# Originally js-multibase/master/test/multibase.spec.js
TEST_7 = [
  ['base16', "\x01", 'f01'],
  ['base16', "\x0f", 'f0f'],
  ['base64', '÷ïÿ', 'mw7fDr8O/'],
  ['base64', '÷ïÿ🥰÷ïÿ😎🥶🤯', 'mw7fDr8O/8J+lsMO3w6/Dv/CfmI7wn6W28J+krw'],
  ['base64url', '÷ïÿ', 'uw7fDr8O_'],
  ['base64url', '÷ïÿ🥰÷ïÿ😎🥶🤯', 'uw7fDr8O_8J-lsMO3w6_Dv_CfmI7wn6W28J-krw'],
  ['base64urlpad', '÷ïÿ🥰÷ïÿ😎🥶🤯', 'Uw7fDr8O_8J-lsMO3w6_Dv_CfmI7wn6W28J-krw==']
].freeze

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
].freeze

# rubocop:enable Metrics/LineLength, Style/WordArray

class MultibasesFixturesTest < Minitest::Test
  [
    [fixture('test1.csv'), 'decentralize_everthing'],
    [fixture('test2.csv'), 'yes_mani'],
    [fixture('test3.csv'), 'hello_world'],
    [fixture('test4.csv'), 'null_yes_mani'],
    [fixture('test5.csv'), 'null_null_yes_mani']
  ].each do |fixture, name|
    fixture.each do |row|
      plain_text = nuller(unquote(row.headers[1].lstrip))
      packed_text = unquote(row[1].lstrip)
      encoding = row['encoding'] || row[0]

      define_method("test_#{encoding}_encode_on_#{name}") do
        packed_result = Multibases.pack(encoding, plain_text).to_s
        assert_equal packed_text, packed_result
      end

      define_method("test_#{encoding}_decode_on_#{name}") do
        plain_result = Multibases.decode(packed_text).to_s(plain_text.encoding)
        assert_equal plain_text, plain_result
      end
    end
  end

  fixture('test6.csv').each do |row|
    plain_text = nuller(unquote(row.headers[1].lstrip))
    packed_text = unquote(row[1].lstrip)
    encoding = row['non-canonical encoding'] || row[0]

    expected_packed_text = if encoding.include?('upper')
                           then packed_text.upcase
                           else packed_text.downcase
                           end

    define_method("test_#{encoding}_encode_hello_world_canonically") do
      packed_result = Multibases.pack(encoding, plain_text).to_s
      assert_equal expected_packed_text, packed_result
    end

    define_method("test_#{encoding}_decode_non_canonical_hello_world") do
      plain_result = Multibases.decode(packed_text).to_s(plain_text.encoding)
      assert_equal plain_text, plain_result
    end
  end

  TEST_7.each_with_index do |row, i|
    encoding = row[0]
    plain_text = row[1].encode(Encoding::UTF_8)
    packed_text = row[2]
    is_valid = plain_text.valid_encoding?

    define_method("test_#{encoding}_encode_on_emojies_#{i}") do
      packed_result = Multibases.pack(encoding, plain_text).to_s
      assert_equal packed_text, packed_result
    end

    define_method("test_#{encoding}_decode_on_emojies_#{i}") do
      plain_result = Multibases.decode(packed_text).to_s(plain_text.encoding)
      assert_equal plain_text, plain_result
      assert_equal is_valid, plain_result.valid_encoding?
    end
  end

  TEST_8.each do |row|
    encoding = row[0]
    plain_text = row[1]
    packed_text = row[2]

    define_method("test_#{encoding}_encode_on_#{plain_text}") do
      packed_result = Multibases.pack(encoding, plain_text).to_s
      assert_equal packed_text, packed_result
    end

    define_method("test_#{encoding}_decode_on_#{plain_text}") do
      plain_result = Multibases.decode(packed_text).to_s(plain_text.encoding)
      assert_equal plain_text, plain_result
    end
  end
end
