# frozen_string_literal: true

require 'fileutils'
require 'jekyll/auto_site'
require 'jekyll/auto_config'
require 'jekyll/page_or_post'

module Jekyll
  # Generates /_auto_redirect.txt, which maps source paths to published URL paths,
  # and writes front matter into new or moved pages.
  # Also writes into 404.html front matter for deleted posts.
  class JekyllAutoRedirect < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(site)
      @auto_config = AutoConfig.new(site)
      return unless @auto_config.enabled

      @site = site
      @site.exclude |= ['_auto_redirect.txt']

      @auto_site = AutoSite.new(@auto_config, @site)
      File.open(@auto_site.auto_redirect_txt, 'w') do |file|
        pages_and_posts.each do |page_or_post|
          PageOrPost.new(@auto_config, @auto_site, page_or_post).generate_page(file)
        end
      end

      @auto_site.redirects.each do |deleted_page_or_post|
        # TODO issue 404 redirects for deleted pages and posts
      end
    end

    def self.interesting_page(page) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      klass_methods = page.class.instance_methods
      has_url_and_path = klass_methods.include?(:url) and klass_methods.include?(:path)
      is_post = page.type == :posts if klass_methods.include? :type
      is_page = page.type == :pages if klass_methods.include? :type
      is_redirects_json = page.name == 'redirects.json' && page.base.empty? if klass_methods.include? :base # Where does this file come from?

      ok = has_url_and_path || is_post || is_page
      ok &&= !is_redirects_json
      ok
    end

    private

    # @return array of pages and posts
    def pages_and_posts
      pages = @site.pages.select { |page| JekyllAutoRedirect.interesting_page page }
      @site.collections.each do |collection|
        docs = collection[1].docs
        interesting_files = docs.select { |doc| JekyllAutoRedirect.interesting_page doc }
        pages |= interesting_files unless interesting_files.empty?
      end
    end
  end
end
