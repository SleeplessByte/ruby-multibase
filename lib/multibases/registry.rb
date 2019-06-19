# frozen_string_literal: true

module Multibases
  # rubocop:disable Style/MutableConstant
  IMPLEMENTATIONS = {}
  # rubocop:enable Style/MutableConstant

  Registration = Struct.new(:code, :encoding, :engine) do
    def hash
      encoding.hash
    end

    def ==(other)
      return [encoding, code].include?(other) if other.is_a?(String)

      eql?(other)
    end

    def eql?(other)
      other.is_a?(Registration) && other.encoding == encoding
    end
  end

  module_function

  def implement(encoding, code, implementation = nil, alphabet = nil)
    Multibases::IMPLEMENTATIONS[encoding] = Registration.new(
      code,
      encoding,
      implementation&.new(alphabet)
    )
  end

  def fetch_by!(code: nil, encoding: nil)
    return Multibases::IMPLEMENTATIONS.fetch(encoding) if encoding

    Multibases.find_by(code: code).tap do |found|
      raise KeyError, "No implementation has code #{code}" unless found
    end
  end

  def find_by(code: nil, encoding: nil)
    Multibases::IMPLEMENTATIONS.values.find do |v|
      v == code || v == encoding
    end
  end

  def multibase_version(multibase_semver = nil)
    return @multibase_version if multibase_semver.nil?

    @multibase_version = multibase_semver
  end
end
