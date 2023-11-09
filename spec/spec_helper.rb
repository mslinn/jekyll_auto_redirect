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

  config.filter_run_when_matching focus: true
  config.order = 'random'

  # See https://relishapp.com/rspec/rspec-core/docs/command-line/only-failures
  config.example_status_persistence_file_path = 'spec/status_persistence.txt'

  def self.source_dir(*files)
    File.join(SOURCE_DIR, *files)
  end

  def self.dest_dir(*files)
    File.join(DEST_DIR, *files)
  end

  def self.robot_fixtures(*subdirs)
    File.join(ROBOT_FIXTURES, *subdirs)
  end

  def setup_fixture(directory)
    ROBOT_FIXTURE_ITEMS.each { |item| FileUtils.cp_r(source_dir(item), robot_fixtures(directory)) }
  end

  def cleanup_fixture(directory, dest_dirname = '_site')
    (ROBOT_FIXTURE_ITEMS + [dest_dirname]).each do |item|
      FileUtils.remove_entry(robot_fixtures(directory, item))
    end
  end
end
