# frozen_string_literal: true

require 'jekyll/front_matter'

module Jekyll
  attr_reader :auto_redirect_txt, :pages_and_posts, :redirects, :site

  class AutoSite
    def initialize(site)
      @auto_redirect_txt = "#{site.source}/_auto_redirect.txt"
      @pages_and_posts = AutoSite.pages_and_posts(site)
      @redirects = AutoSite.auto_redirects(@auto_redirect_txt)
      @site = site
    end

    # @return array of pages and posts
    def self.pages_and_posts(site)
      pages = site.pages.select { |page| interesting_page page }
      site.collections.each do |collection|
        docs = collection[1].docs
        interesting_files = docs.select { |doc| interesting_page doc }
        pages |= [interesting_files] unless interesting_files.empty?
      end
      pages.flatten
    end
  end

  # @return map of id => path
  def self.auto_redirects(auto_redirect_txt)
    return [] unless File.exist? auto_redirect_txt

    hash = {}
    IO.readlines(auto_redirect_txt, chomp => true).each do |line|
      hash.merge!(Hash[*line.split])
    end
  end
end
