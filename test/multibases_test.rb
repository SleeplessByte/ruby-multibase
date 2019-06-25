# frozen_string_literal: true

require 'test_helper'

class MultibasesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Multibases::VERSION
  end

  def test_that_it_has_a_spec_number
    refute_nil ::Multibases.multibase_version
  end

  def test_it_has_a_public_api
    # If one of these assertions changes, breaking change
    assert_respond_to ::Multibases, :encode
    assert_respond_to ::Multibases, :unpack
    assert_respond_to ::Multibases, :decorate
    assert_respond_to ::Multibases, :pack
    assert_respond_to ::Multibases, :decode
    assert_respond_to ::Multibases, :encoding
    assert_respond_to ::Multibases, :code
    assert_respond_to ::Multibases, :engine
  end

  def test_it_can_create_encoded_structs
    encoded = ::Multibases.encode('base2', 'abc')

    # If one of these assertions changes, breaking change
    assert_respond_to encoded, :code
    assert_respond_to encoded, :encoding
    assert_respond_to encoded, :length
    assert_respond_to encoded, :data
    assert_respond_to encoded, :pack
    assert_respond_to encoded, :decode
  end

  def test_it_can_encode_plain_data
    encoded = ::Multibases.encode('base2', 'abc')
    assert_equal 24, encoded.length
    assert_equal 'base2', encoded.encoding
    assert_equal '0', encoded.code
    assert_equal '011000010110001001100011', encoded.data.to_s
  end

  def test_it_can_pack_encoded_data
    encoded = ::Multibases.encode('base2', 'abc')
    packed = encoded.pack
    assert_equal 25, packed.length
    assert_equal '0'.ord, packed[0]
    assert_equal '0011000010110001001100011', packed.to_s
  end

  def test_it_can_decode_encoded_data
    encoded = ::Multibases.encode('base2', 'abc')
    decoded = encoded.decode
    assert_equal 3, decoded.length
    assert_equal 'abc', decoded.to_s(Encoding::ASCII_8BIT)
  end

  def test_it_can_unpack_packed_data
    encoded = ::Multibases.unpack('0011000010110001001100011')
    assert_equal 24, encoded.length
    assert_equal 'base2', encoded.encoding
    assert_equal '0', encoded.code
    assert_equal '011000010110001001100011',
                 encoded.data.to_s(Encoding::ASCII_8BIT)
  end

  def test_it_can_decorate_packed_data
    packed = '011000010110001001100011'
    assert_equal 24, packed.length

    decorated = ::Multibases.decorate(packed, 'base2')
    assert_equal 25, decorated.length
    assert_equal '0011000010110001001100011',
                 decorated.to_s(Encoding::ASCII_8BIT)
  end

  def test_it_can_decorate_encoded_data
    encoded = ::Multibases.encode('base2', 'abc')
    assert_equal 24, encoded.length

    decorated = ::Multibases.decorate(encoded, 'base2')
    assert_equal 25, decorated.length
    assert_equal '0011000010110001001100011', decorated.to_s
  end

  def test_it_can_pack_plain_data
    packed = ::Multibases.pack('base2', 'abc')
    assert_equal 25, packed.length
    assert_equal '0011000010110001001100011', packed.to_s
  end

  def test_it_can_retrieve_engine_by_code
    engine = ::Multibases.engine("\x00")
    assert_kind_of ::Multibases::Identity, engine
  end

  def test_it_can_retrieve_engine_by_encoding_name
    engine = ::Multibases.engine('identity')
    assert_kind_of ::Multibases::Identity, engine
  end

  def test_it_can_retrieve_code_by_encoding_name
    code = ::Multibases.code('identity')
    assert_equal "\x00", code
  end

  def test_it_can_retrieve_encoding_name_by_code
    encoding = ::Multibases.encoding("\x00")
    assert_equal 'identity', encoding
  end

  def test_the_wrapper_adds_the_code
    ::Multibases.names.each do |encoding|
      next unless ::Multibases.engine(encoding)
      packed = ::Multibases.pack(encoding, 'abc')
      encoded = ::Multibases.engine(encoding).encode('abc')
      assert_equal packed.length, encoded.length + ::Multibases.code(encoding).length
    end
  end
end
