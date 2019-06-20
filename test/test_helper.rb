# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'multibases'
require 'minitest/autorun'

def fixture(name)
  CSV.open(File.join(__dir__, 'fixtures', name), headers: true, quote_char: "\x00")
end

def unquote(str)
  s = str.dup

  case str[0,1]
  when "'", '"', '`'
    s[0] = ''
  end

  case str[-1,1]
  when "'", '"', '`'
    s[-1] = ''
  end

  return s
end

def nuller(str)
  str.gsub('\x00', "\x00")
end
