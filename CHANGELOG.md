# Changelog

## 0.3.0

- Fix convenience methods `names` and `codes`.
- Add `encoding` to `ByteArray` in order to not _guess_ the output encoding. The
  encoding is determined in the encoding engine (when encoding) and has to be
  supplied when decoding (because the encoding information is thrown away).
- Force `encoding` argument in `to_s` of `ByteArray`
- Extract errors to `error.rb`.
- Extract table strictness to its own method.

## 0.2.0

- Add convenience methods to registry, like `multicodecs`.
- Change tests to use fixture files and add `rake` task to update these.

## 0.1.0

:baby: intial release
