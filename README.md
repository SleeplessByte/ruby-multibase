# Multibases

[![Build Status](https://travis-ci.com/SleeplessByte/ruby-multibase.svg?branch=master)](https://travis-ci.com/SleeplessByte/ruby-multibase)
[![Gem Version](https://badge.fury.io/rb/multibases.svg)](https://badge.fury.io/rb/multibases)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![Maintainability](https://api.codeclimate.com/v1/badges/1253cc22b664d27d4052/maintainability)](https://codeclimate.com/github/SleeplessByte/ruby-multibase/maintainability)

> Multibase is a protocol for disambiguating the encoding of base-encoded
> (e.g., base32, base64, base58, etc.) binary appearing in text.

`Multibases` is the ruby implementation of [multiformats/multibase][spec].

This gem can be used _both_ for encoding into or decoding from multibase packed
strings, as well as serve as a _general purpose_ library to do `BaseX` encoding
and decoding _without_ adding the prefix.

## Installation

Add this line to your application's Gemfile:

```Ruby
gem 'multibases'
```

or alternatively if you would like to bring your own engines and not load any
of the built-in ones:

```Ruby
gem 'multibases', require: 'multibases/bare'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multibases

## Usage

This is a low-level library, but high level implementations are provided.
You can also bring your own encoder/decoder. The most important methods are:

- `Multibases.encode(encoding, data, engine?)`: encodes the given data with a
  built-in engine for encoding, or engine if it's given. Returns an `Encoded`
  PORO that has `pack`.
- `Multibases.unpack(packed)`: decodes a multibase packed string into an
  `Encoded` PORO that has `decode`.
- `Multibases::Encoded.pack`: packs the multihash into a single string
- `Multibases::Encoded.decode(engine?)`: decodes the PORO's data using a
  built-in engine, or engine if it's given. Returns a decoded `ByteArray`.

```ruby
encoded = Multibases.encode('base2', 'mb')
# => #<struct Multibases::Encoded
#             code="0", encoding="base2", length=16,
#             data=[Multibases::EncodedByteArray "0110110101100010"]>

encoded.pack
# => [Multibases::EncodedByteArray "00110110101100010"]


encoded = Multibases.unpack('766542')
# => #<struct Multibases::Encoded
#             code="7", encoding="base8", length=5,
#             data=[Multibases::EncodedByteArray "66542"]>

encoded.decode
# => [Multibases::DecodedByteArray "mb"]
```

This means that the flow of calls is as follows:

```text
        data ➡️ (encode) ➡️ encoded data
encoded data ➡️ (pack)   ➡️ multibasestr

multibasestr ➡️ (unpack) ➡️ encoded data
encoded data ➡️ (decode) ➡️ data
```

Convenience methods are provided:

- `Multibases.pack(encoding, data, engine?)`: calls `encode` and then `pack`
- `Multibases.decode(packed, engine?)`: calls `unpack` and then `decode`

```ruby
Multibases.pack('base2', 'mb')
# => [Multibases::EncodedByteArray "00110110101100010"]
```

### ByteArrays and encoding

As you can see, the "final" methods output a `ByteArray`. These are simple
`DelegateClass` wrappers around the array with bytes, which means that the `hex`
encoding of `hello` is not actually stored as `"f68656c6c6f"`:

```ruby
packed = Multibases.pack('base16', 'hello')
# => [Multibases::EncodedByteArray "f68656c6c6f"]

packed.to_a # .__getobj__.dup
# => [102, 54, 56, 54, 53, 54, 99, 54, 99, 54, 102]
```

They override `inspect` and _force_ the encoding to `UTF-8` (in inspect), but
you can use the convenience methods to use the correct encoding:

> **Note**: If you're using `pry` and have not changed the printer, you
> naturally won't see the output as described above, but instead see the inner
> Array of bytes, always.

```ruby
data = 'hello'.encode('UTF-16LE')
data.encoding
# => #<Encoding:UTF-16LE>

data.bytes
# => [104, 0, 101, 0, 108, 0, 108, 0, 111, 0]

packed = Multibases.pack('base16', data)
# => [Multibases::EncodedByteArray "f680065006c006c006f00"]

decoded = Multibases.decode(packed)
# => [Multibases::DecodedByteArray "h e l l o "]

decoded.to_s('UTF-16LE')
# => "hello"
```

### Implementations

You can find the _current_ multibase table [here][git-multibase-table]. At this
moment, built-in engines are provided as follows:

| encoding          | code | description                       | implementation |
|-------------------|------|-----------------------------------|----------------|
| identity          | 0x00 | 8-bit binary                      | `bare`         |
| base1             | 1    | unary (1111)                      | ❌              |
| base2             | 0    | binary (0101)                     | `base2` 💨      |
| base8             | 7    | octal                             | `base_x`       |
| base10            | 9    | decimal                           | `base_x`       |
| base16            | f    | hexadecimal                       | `base16` 💨     |
| base16upper       | F    | hexadecimal                       | `base16` 💨     |
| base32hex         | v    | rfc4648 no padding - highest char | `base32` ✨     |
| base32hexupper    | V    | rfc4648 no padding - highest char | `base32` ✨     |
| base32hexpad      | t    | rfc4648 with padding              | `base32` ✨     |
| base32hexpadupper | T    | rfc4648 with padding              | `base32` ✨     |
| base32            | b    | rfc4648 no padding                | `base32` ✨     |
| base32upper       | B    | rfc4648 no padding                | `base32` ✨     |
| base32pad         | c    | rfc4648 with padding              | `base32` ✨     |
| base32padupper    | C    | rfc4648 with padding              | `base32` ✨     |
| base32z           | h    | z-base-32 (used by Tahoe-LAFS)    | `base32` ✨     |
| base58flickr      | Z    | base58 flicker                    | `base_x`       |
| base58btc         | z    | base58 bitcoin                    | `base_x`       |
| base64            | m    | rfc4648 no padding                | `base64` 💨     |
| base64pad         | M    | rfc4648 with padding - MIME enc   | `base64` 💨     |
| base64url         | u    | rfc4648 no padding                | `base64` 💨     |
| base64urlpad      | U    | rfc4648 with padding              | `base64` 💨     |

Those with a 💨 are marked because they are backed by a C implementation (using
`pack` and `unpack`) and are therefore suposed to be blazingly fast. Those with
a ✨ are marked because they have a custom implementation over the generic
`base_x` implementation. It should be faster.

The version of the spec that this repository was last updated for is available
via `Multibases.multibase_version`:

```ruby
Multibases.multibase_version
# => "1.0.0"
```

### Bring your own engine

The methods of `multibases` allow you to bring your own engine, and you can safe
additional memory by only loading `multibases/bare`.

```ruby
# Note: This is not how multibase was meant to work. It's supposed to only
#       convert the input from one base to another, and denote what that base
#       is, stored in the output. However, the system is _so_ flexible that this
#       works perfectly for any reversible transformation!
class EngineKlazz
  def initialize(*_)
  end

  def encode(plain)
    plain = plain.bytes unless plain.is_a?(Array)
    Multibases::EncodedByteArray.new(plain.reverse)
  end

  def decode(encoded)
    encoded = encoded.bytes unless encoded.is_a?(Array)
    Multibases::DecodedByteArray.new(encoded.reverse)
  end
end

Multibases.implement 'reverse', 'r', EngineKlazz, 'alphabet'
# => Initializes EngineKlazz with 'alphabet'

Multibases.pack('reverse', 'md')
# => [Multibases::EncodedByteArray "rdm"]

Multibases.decode('dm')
# => [Multibases::DecodedByteArray "md"]

# Alternatively, you can pass the instantiated engine to the appropriate
# function.
engine = EngineKlazz.new

# Mark the encoding as "existing" and attach a code
Multibases.implement 'reverse', 'r'

# Pack, using a custom engine
Multibases.pack('reverse', 'md', engine)
# => [Multibases::EncodedByteArray "rdm"]

Multibases.decode('rdm', engine)
# => [Multibases::DecodedByteArray "md"]
```

### Using the built-in encoders/decoders

You can use the built-in encoders and decoders.

```ruby
require 'multibases/base16'

Multibases::Base16.encode('foobar')
# => [Multibases::EncodedByteArray "666f6f626172"]

Multibases::Base16.decode('666f6f626172')
# => [Multibases::DecodedByteArray "foobar"]
```

These don't add the `multibase` prefix to the output and they use the canonical
`encode` and `decode` nomenclature.

The `base_x` / `BaseX` encoder does not have a module function. You _must_
instantiate it first. The result is an encoder that uses the base alphabet to
determine its base. Currently padding is ❌ not supported for `BaseX`, but
might be in a future update using a second argument or key.

```ruby
require 'multibases/base_x'

Base3 = Multibases::BaseX.new('012')
# => [Multibases::Base3 alphabet="012" strict]

Base3.encode('foobar')
# => [Multibases::EncodedByteArray "112202210012121110020020001100"]
```

You can use the same technique to inject a custom alphabet. This can be used on
the built-in encoders, even the ones that are not `BaseX`:

```ruby
base = Multibases::Base2.new('.!')
# => [Multibases::Base2 alphabet=".!"]

base.encode('foo')
# [Multibases::EncodedByteArray ".!!..!!..!!.!!!!.!!.!!!!"]

base.decode('.!!...!..!!....!.!!!..!.')
# => [Multibases::DecodedByteArray "bar"]
```

All the built-in encoder/decoders take strings, arrays or byte-arrays as input.

```ruby
expected = Multibases::Base16.encode("abc")
# => [Multibases::EncodedByteArray "616263"]

expected == Multibases::Base16.encode([97, 98, 99])
# => true

expected == Multibases::Base16.encode(Multibases::ByteArray.new("abc".bytes))
# => true
```

## Related

- [`multiformats/multibase`][git-multibase]: the spec repository
- [`multiformats/ruby-multicodec`][git-ruby-multicodec]: the ruby implementation of [`multiformats/multicodec`][git-multicodec]
- [`multiformats/ruby-multihash`][git-ruby-multihash]: the ruby implementation of [`multiformats/multihash`][git-multihash]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org][web-rubygems].

## Contributing

Bug reports and pull requests are welcome on GitHub at [SleeplessByte/ruby-multibase][git-self].
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor Covenant][web-coc] code
of conduct.

## License

The gem is available as open source under the terms of the [MIT License][web-mit].

## Code of Conduct

Everyone interacting in the Shrine::ConfigurableStorage project’s codebases,
issue trackers, chat rooms and mailing lists is expected to follow the
[code of conduct][git-self-coc].

[spec]: https://github.com/multiformats/multibase
[git-self-coc]: https://github.com/SleeplessByte/ruby-multibase/blob/master/CODE_OF_CONDUCT.md
[git-self]: https://github.com/SleeplessByte/ruby-multibase
[git-ruby-multicodec]: https://github.com/SleeplessByte/ruby-multicodec
[git-multicodec]:  https://github.com/multiformats/multicodec
[git-multibase]:  https://github.com/multiformats/multibase
[git-multibase-table]: https://github.com/multiformats/multibase/blob/master/multibase.csv
[git-ruby-multihash]: https://github.com/multiformats/ruby-multihash
[git-multihash]: https://github.com/multiformats/multihash
[web-coc]: http://contributor-covenant.org
[web-mit]: https://opensource.org/licenses/MIT
[web-rubygems]: https://rubygems.org

