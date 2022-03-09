# frozen_string_literal: true

module Jekyll
  attr_reader :config, :dead_page_dirs, :dead_post_dirs, :dead_urls

  class AutoConfig
    def initialize(site)
      @config = site.config
      @dead_page_dirs = @config['dead_page_dirs'] || []
      @dead_post_dirs = @config['dead_post_dirs'] || []
      @dead_urls = @config['dead_urls'] || []
      @enabled = @config['enabled'] || true
      @verbose = @config['verbose'] || false
    end

    def info(msg)
      Jekyll.logger.info(msg) if @verbose
    end
  end
end
