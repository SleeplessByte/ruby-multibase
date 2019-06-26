# frozen_string_literal: true

require 'test_helper'

module Multibases
  class ByteArrayTest < Minitest::Test
    def test_it_equals_the_inner_content
      original = [1, 2, 3]
      generic_array = ByteArray.new([1, 2, 3])
      encoded_array = EncodedByteArray.new([1, 2, 3])
      decoded_array = DecodedByteArray.new([1, 2, 3])

      assert_equal original, generic_array
      assert_equal original, encoded_array
      assert_equal original, decoded_array

      assert_equal encoded_array, decoded_array
    end

    def test_it_inequals_the_inner_content
      original = [1, 2, 3]
      different = [3, 2, 1]
      generic_array = ByteArray.new([3, 2, 1])
      encoded_array = EncodedByteArray.new([3, 2, 1])
      decoded_array = DecodedByteArray.new([3, 2, 1])

      refute_equal original, different
      refute_equal original, generic_array
      refute_equal original, encoded_array
      refute_equal original, decoded_array
    end

    def test_it_can_transcode
      original = ByteArray.new([1, 2, 3])
      expected = [3, 6, 9]
      original_alphabet = [1, 2, 3, 4, 5, 6, 7, 8, 9]
      new_alphabet = [3, 6, 9, 1, 2, 4, 5, 7, 8]

      transcoded = original.transcode(original_alphabet, new_alphabet)

      refute_equal original, transcoded
      assert_equal expected, transcoded
    end

    def test_it_can_unwrap
      original = ByteArray.new([1, 2, 3])

      unwrapped = original.to_a
      unwrapped_alias = original.to_arr

      refute_equal original.object_id, unwrapped.object_id
      refute_equal original.object_id, unwrapped_alias.object_id

      # test that each call gives a fresh copy
      refute_equal unwrapped.object_id, original.to_a

      refute_kind_of ByteArray, unwrapped
      refute_kind_of ByteArray, unwrapped_alias

      assert_equal [1, 2, 3], unwrapped
      assert_equal [1, 2, 3], unwrapped_alias
    end

    def test_it_requires_a_string_encoding
      byte_array_of_abc = DecodedByteArray.new([97, 98, 99])

      assert_raises(MissingEncoding) do
        byte_array_of_abc.to_s
      end
    end

    def test_it_accepts_a_string_encoding_on_creation
      abc = [97, 98, 99]
      hex_abc = [54, 49, 54, 50, 54, 51]
      encoding = Encoding::US_ASCII

      byte_array_of_abc = DecodedByteArray.new(abc, encoding: encoding)
      byte_array_of_hex_abc = EncodedByteArray.new(hex_abc, encoding: encoding)

      assert_equal encoding, byte_array_of_abc.to_s.encoding
      assert_equal encoding, byte_array_of_hex_abc.to_s.encoding
    end

    def test_it_accepts_a_string_encoding_on_call
      abc = [97, 98, 99]
      hex_abc = [54, 49, 54, 50, 54, 51]
      encoding = Encoding::US_ASCII

      byte_array_of_abc = DecodedByteArray.new(abc)
      byte_array_of_hex_abc = EncodedByteArray.new(hex_abc)

      str_of_abc = byte_array_of_abc.to_s(encoding)
      str_of_hex_abc = byte_array_of_hex_abc.to_s(encoding)

      assert_equal encoding, str_of_abc.encoding
      assert_equal encoding, str_of_hex_abc.encoding
    end
  end
end
