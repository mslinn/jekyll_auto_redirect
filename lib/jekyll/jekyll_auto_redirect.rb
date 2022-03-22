# frozen_string_literal: true

require 'fileutils'
require "jekyll_plugin_logger"
require_relative './auto_site'
require_relative './auto_config'
require_relative './page_or_post'
require_relative '../warn'
require_relative '../jekyll_auto_redirect/version'

module JekyllAutoRedirectPluginName
  PLUGIN_NAME = "jekyll_auto_redirect"
end

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
          unless page_or_post.class.instance_methods.include? :path
            puts "Oops, generate: #{@page}"
          end
          PageOrPost.new(@auto_config, @auto_site, page_or_post).generate_page(file)
        end
      end

      @auto_site.redirects.each do |deleted_page_or_post|
        # TODO issue 404 redirects for deleted pages and posts
      end
    end

    def self.interesting_page(page)
      klass = page.class
      klass_methods = klass.instance_methods
      has_url_and_path = klass_methods.include?(:url) and klass_methods.include?(:path)
      is_post = page.type == :posts if klass_methods.include? :type
      is_page = page.type == :pages if klass_methods.include? :type
      is_page_without_a_file = klass.name.split('::').last == 'PageWithoutAFile' # Where does this file come from?

      ok = has_url_and_path || is_post || is_page
      ok &&= !is_page_without_a_file
      ok
    end

    private

    # @return array of pages and posts
    def pages_and_posts
      pages = @site.pages.select { |page| JekyllAutoRedirect.interesting_page page }
      @site.collections.each_value do |collection|
        interesting_files = collection.docs.select { |doc| JekyllAutoRedirect.interesting_page doc }
        pages |= interesting_files unless interesting_files.empty?
      end
      pages
    end
  end
end

PluginMetaLogger.instance.info { "Loaded #{JekyllAutoRedirectPluginName::PLUGIN_NAME} v#{JekyllAutoRedirect::VERSION} plugin." }
