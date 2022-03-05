# frozen_string_literal: true

require 'fileutils'

module Jekyll
  # Generates /_page_lookup.txt, which maps source paths to published URL paths
  class JekyllPageLookup < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(site)
      @site = site
      @site.pages << page_lookup # unless file_exists?('_page_lookup.txt')
      Jekyll.logger "#{@site.pages.length} pages were found."
    end

    private

    INCLUDED_EXTENSIONS = %w[
      .md
      .htm
      .html
      .xhtml
    ].freeze

    # Matches all whitespace that follows
    #   1. A '>' followed by a newline or
    #   2. A '}' which closes a Liquid tag
    # We will strip all of this whitespace to minify the template
    MINIFY_REGEX = /!(?<=>\n|})\s+/.freeze

    # Array of all non-jekyll site files with an HTML extension
    def static_files
      @site.static_files.select { |file| INCLUDED_EXTENSIONS.include? file.extname }
    end

    # Destination for _page_lookup.txt file within the site source directory
    def destination_path(file = '_page_lookup.txt')
      File.expand_path "../#{file}", __dir__
    end

    def page_lookup
      output = PageWithoutAFile.new(@site, __dir__, '', '_page_lookup.txt')
      output.content = File.read(destination_path).gsub(MINIFY_REGEX, '')
      # output.data["layout"] = nil
      # output.data["static_files"] = static_files.map(&:to_liquid)
      output
    end

    # Checks if a file already exists in the site source
    def file_exists?(file_path)
      pages_and_files.any? { |p| p.url == "/#{file_path}" }
    end

    def pages_and_files
      @pages_and_files ||= @site.pages + @site.static_files
    end
  end
end
