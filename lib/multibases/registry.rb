module Multibases
  IMPLEMENTATIONS = {}

  module_function

  def implement(encoding, code, implementation, alphabet)
    Multibases::IMPLEMENTATIONS[code] = {
      encoding: encoding,
      engine: implementation && implementation.new(alphabet)
    }
  end

  def fetch(code, &block)
    Multibases::IMPLEMENTATIONS.fetch(code, &block)
  end

  def find(encoding)
    Multibases::IMPLEMENTATIONS.find do |_, v|
      v[:encoding] == encoding
    end
  end

  def version(multibase_semver)
    @spec_version = multibase_semver
  end

  def spec_version
    @spec_version
  end
end
