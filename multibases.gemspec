# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multibases/version'

Gem::Specification.new do |spec|
  spec.name          = 'multibases'
  spec.version       = Multibases::VERSION
  spec.authors       = ['Derk-Jan Karrenbeld']
  spec.email         = ['derk-jan+github@karrenbeld.info']
  spec.license       = 'MIT'

  spec.summary       = 'Ruby implementation of the multibase specification'
  spec.description   = %q(
    This is a low-level library, but high level implementations are provided.
    You can also bring your own encoder/decoder. This gem can be used _both_ for
    encoding into or decoding from multibase packed strings, as well as serve as
    a _general purpose_ library to do `BaseX` encoding and decoding _without_
    adding the prefix.
  ).strip
  spec.homepage = 'https://github.com/SleeplessByte/ruby-multibase'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/SleeplessByte/ruby-multibase'
    spec.metadata['changelog_uri'] = spec.metadata['source_code_uri'] +
                                     '/blog/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
