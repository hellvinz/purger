# -*- encoding: utf-8 -*-
require File.expand_path('../lib/varnish-purger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vincent Hellot"]
  gem.email         = ["hellvinz@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "varnish-purger"
  gem.require_paths = ["lib"]
  gem.version       = Varnish::Purger::VERSION

  gem.add_dependency "ffi-rzmq"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "yard"
  gem.add_development_dependency "redcarpet"
  gem.test_files = Dir.glob('spec/*_spec.rb')
end
