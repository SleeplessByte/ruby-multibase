# Multibases

[![Build Status: master](https://travis-ci.com/SleeplessByte/ruby-multibase.svg?branch=master)](https://travis-ci.com/SleeplessByte/ruby-multibase)
[![Gem Version](https://badge.fury.io/rb/ruby-multibase.svg)](https://badge.fury.io/rb/ruby-multibase)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![Maintainability](https://api.codeclimate.com/v1/badges/1e5600a4be90eec063e0/maintainability)](https://codeclimate.com/repos/5d094b036bd112014f005f98/maintainability)

> Multibase is a protocol for disambiguating the encoding of base-encoded
> (e.g., base32, base64, base58, etc.) binary appearing in text.

`Multibases` is the ruby implementation of [multiformats/multibase][spec]


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
You can also bring your own encoder/decoded. The most important methods are:

- `Multibases.encode(encoding, data, engine?)`: encodes the given data with a
  built-in engine for encoding, or engine if it's given. Returns an `Encoded`
  PORO that has `pack`.
- `Multibases.unpack(packed)`: decodes a multibase packed string into an
  `Encoded` PORO that has `decode`.
- `Multibases::Encoded.pack`: packs the multihash into a single string
- `Multibases::Encoded.decode(engine?)`: decodes the PORO's data using a
  built-in engine, or engine if it's given. Returns a decoded `String`.

```ruby
encoded = Multibases.encode('base2', 'mb')
# => #<struct Multibases::Encoded code="0", encoding="base2", length=16, data="0110110101100010">

encoded.pack
# => "00110110101100010"

encoded = Multibases.unpack('766542')
# => #<struct Multibases::Encoded code="7", encoding="base8", length=5, data="66542">

encoded.decode
# => "mb"
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
# => "00110110101100010"
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
| base16            | f    | hexadecimal                       | `base_16` 💨    |
| base16upper       | F    | hexadecimal                       | `base_16` 💨    |
| base32hex         | v    | rfc4648 no padding - highest char | `base_32` ✨    |
| base32hexupper    | V    | rfc4648 no padding - highest char | `base_32` ✨    |
| base32hexpad      | t    | rfc4648 with padding              | `base_32` ✨    |
| base32hexpadupper | T    | rfc4648 with padding              | `base_32` ✨    |
| base32            | b    | rfc4648 no padding                | `base_32` ✨    |
| base32upper       | B    | rfc4648 no padding                | `base_32` ✨    |
| base32pad         | c    | rfc4648 with padding              | `base_32` ✨    |
| base32padupper    | C    | rfc4648 with padding              | `base_32` ✨    |
| base32z           | h    | z-base-32 (used by Tahoe-LAFS)    | `base_32` ✨    |
| base58flickr      | Z    | base58 flicker                    | `base_x`       |
| base58btc         | z    | base58 bitcoin                    | `base_x`       |
| base64            | m    | rfc4648 no padding                | `base_64` 💨    |
| base64pad         | M    | rfc4648 with padding - MIME enc   | `base_64` 💨    |
| base64url         | u    | rfc4648 no padding                | `base_64` 💨    |
| base64urlpad      | U    | rfc4648 with padding              | `base_64` 💨    |

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

  def encode(plain_text)
    plain_text.reverse
  end

  def decode(encoded_text)
    encoded_text.reverse
  end
end

Multibases.implement 'reverse', 'r', EngineKlazz, 'alphabet'
# => Initializes EngineKlazz with 'alphabet'

Multibases.pack('reverse', 'md')
# => "rdm"

Multibases.decode('dm')
# => "md"

# Alternatively, you can pass the instantiated engine to the appropriate
# function.
engine = EngineKlazz.new

# Mark the encoding as "existing" and attach a code
Multibases.implement 'reverse', 'r'

# Pack, using a custom engine
Multibases.pack('reverse', 'md', engine)
# => "rdm"

Multibases.decode('rdm', engine)
# => "md"
```

## Related

- [`multiformats/multibase`][git-multibase]: the spec repository
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

Bug reports and pull requests are welcome on GitHub at [SleeplessByte/commmand][git-self].
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
[git-multibase]:  https://github.com/multiformats/multibase
[git-multibase-table]: https://github.com/multiformats/multibase/blob/master/multibase.csv
[git-ruby-multihash]: https://github.com/multiformats/ruby-multihash
[git-multihash]: https://github.com/multiformats/multihash
[web-coc]: http://contributor-covenant.org
[web-mit]: https://opensource.org/licenses/MIT
[web-rubygems]: https://rubygems.org

