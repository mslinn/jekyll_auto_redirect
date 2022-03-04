# frozen_string_literal: true

require_relative "lib/jekyll_page_lookup/version"

Gem::Specification.new do |spec|
  spec.name        = "jekyll_page_lookup"
  spec.summary     = "Automatically generate a _page_lookup.txt for your Jekyll site."
  spec.version     = Jekyll::PageLookup::VERSION
  spec.authors     = ["Mike Slinn"]
  spec.email       = "mslinn@mslinn.com"
  spec.homepage    = "https://github.com/mslinn/jekyll_page_lookup"
  spec.licenses    = ["MIT"]

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r!^bin/!) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r!^(test|spec|features)/!)
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "debase"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.12.0"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "ruby-debug-ide"
end
