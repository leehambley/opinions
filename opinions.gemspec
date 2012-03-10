# -*- encoding: utf-8 -*-
require File.expand_path('../lib/opinions/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Lee Hambley"]
  gem.email         = ["lee.hambley@gmail.com"]
  gem.description   = %q{A toolkit for storing user votes/opinions in Redis}
  gem.summary       = %q{Opinions allows the storage of opinions in Redis, a fast and atomic structured data store. If one's users hate, love, appreciate, despise or just-don-t-care, one can store that easily via a simple API.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "opinions"
  gem.require_paths = ["lib"]
  gem.version       = Opinions::VERSION

  gem.add_dependency('redis')

  gem.add_development_dependency('minitest', ['>= 2.11.3', '< 2.12.0'])
  gem.add_development_dependency('autotest')
  gem.add_development_dependency('turn')

  gem.add_development_dependency('daemon_controller')

end
