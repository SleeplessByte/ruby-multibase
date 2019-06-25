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

  class AlphabetOutOfRange < Error
    def initialize(ord)
      super(
        'The multibase spec currently only allows for alphabet characters in ' \
        "the 0-255 range. '#{ord}' is outside that range."
      )
    end
  end

  class AlphabetEncodingInvalid < Error
    def initialize(encoding)
      super(
        "The encoding '#{encoding}' is invalid for the given alphabet. " \
        'Supply an encoding that is valid for each character in the alphabet.'
      )
    end
  end

  class MissingEncoding < Error
    def initialize
      super 'Can not convert from ByteArray to string without encoding. Pass ' \
            'the resulting string encoding as the first argument of to_s.' \
            "\n" \
            'This does not default to UTF-8 or US-ASCII because that would ' \
            'hide issues until you have output that is NOT encoding as UTF-8 ' \
            'or US-ASCII and does not fit in those ranges.'
    end
  end
end
