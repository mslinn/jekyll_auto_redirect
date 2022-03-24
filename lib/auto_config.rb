# frozen_string_literal: true

class AutoConfig
  attr_reader :dead_page_dirs, :dead_post_dirs, :dead_urls, :enabled, :verbose

  def initialize(site)
    config = site.config
    @dead_page_dirs = config['dead_page_dirs'] || []
    @dead_post_dirs = config['dead_post_dirs'] || []
    @dead_urls = config['dead_urls'] || []
    @enabled = config['enabled'] || true
  end
end
