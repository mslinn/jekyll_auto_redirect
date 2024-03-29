require 'jekyll'
require 'fileutils'
require 'jekyll_plugin_logger'
require_relative '../lib/jekyll_auto_redirect'

SOURCE_DIR = File.expand_path('fixtures', __dir__)
DEST_DIR   = File.expand_path('dest', __dir__)
ROBOT_FIXTURES = File.expand_path('robot-fixtures', __dir__)
ROBOT_FIXTURE_ITEMS = %w[_posts _layouts _config.yml index.html].freeze

RSpec.configure do |config|
  _logger = PluginLogger.new(self)

  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  # See https://relishapp.com/rspec/rspec-core/docs/command-line/only-failures
  config.example_status_persistence_file_path = 'spec/status_persistence.txt'

  config = instance_double(Configuration)

  page1 = instance_double(Page)
  allow(page1).to receive(:basename).and_return 'path1.html'
  allow(page1).to receive(:path).and_return '/bogus/path1.html'

  site = instance_double(Site)
  allow(site).to receive(:config) { config }
  allow(site).to receive(:pages) { [page1] }
  allow(site).to receive(:source) { Dir.pwd }

  auto_site = instance_double(AutoSite.new(config, site))
  allow(auto_site).to receive(:auto_redirects).and_return []
end
