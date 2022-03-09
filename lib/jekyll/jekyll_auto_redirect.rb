# frozen_string_literal: true

require 'fileutils'
require 'jekyll/auto_site'
require 'jekyll/auto_config'
require 'jekyll/page_or_post'

module Jekyll
  # Generates /_auto_redirect.txt, which maps source paths to published URL paths
  class JekyllAutoRedirect < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(site)
      auto_config = AutoConfig.new(site)
      return unless auto_config.enabled

      site.exclude |= ['_auto_redirect.txt']
      pages_and_posts = AutoSite.new(site).pages_and_posts
      File.open(auto_redirect_txt, 'w') do |file|
        pages_and_posts.each { |page_or_post| PageOrPost.new(auto_config, auto_site, page_or_post).generate_page(file) }
      end
      # TODO process remaining items in @auto_redirects; they are deleted pages and posts
    end
  end
end
