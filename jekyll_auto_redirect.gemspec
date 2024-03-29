require_relative 'lib/jekyll_auto_redirect/version'

Gem::Specification.new do |spec|
  github = 'https://github.com/mslinn/jekyll_auto_redirect'

  spec.authors = ['Mike Slinn']
  spec.bindir = 'exe'
  spec.description = <<~END_OF_DESC
    Automatically generate HTTP 301 redirects for pages that are moved or deleted on Jekyll site.
  END_OF_DESC
  spec.email = 'mslinn@mslinn.com'
  spec.files = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', '{lib,spec}/**/*', '*.gemspec', '*.md']
  spec.homepage = github
  spec.license = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{github}/issues",
    'changelog_uri'     => "#{github}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => github,
  }
  spec.name = 'jekyll_auto_redirect'
  spec.post_install_message = <<~END_MESSAGE

    Thanks for installing #{spec.name}!

  END_MESSAGE
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6.0'
  spec.summary = 'Automatically generate HTTP 301 redirects for pages that are moved or deleted on Jekyll site.'
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.version = JekyllAutoRedirectVersion::VERSION

  spec.add_dependency 'jekyll', '>= 3.5.0'
  spec.add_dependency 'jekyll_plugin_logger', '>=2.1.1'
end
