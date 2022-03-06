# frozen_string_literal: true

require 'fileutils'

module Jekyll
  # Generates /_page_lookup.txt, which maps source paths to published URL paths
  class JekyllPageLookup < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(site)
      pages = assemble_pages(site)
      File.open(page_lookup_txt, 'w') do |file|
        pages.each do |page|
          # Jekyll.logger.info "#{page.name} path: #{page.relative_path} URL path: #{page.url}"
          Jekyll.logger.info "#{page.name} is a #{type(page)}"
          file.puts "#{page.relative_path} #{page.url}" if page.ext == '.html' && type(pages[0]) == Jekyll::StaticFile
        end
      end
    end

    private

    def interesting_page(page)
      ok = false
      ok = page.html? if page.class.method_defined? :html?
      ok &&= page.base == @site.source if page.class.method_defined? :base
      ok
    end

    def assemble_pages(site)
      @site = site
      pages = site.pages.select { |page| interesting_page page }
      site.collections.each do |collection|
        docs = collection[1].docs
        interesting_files = docs.select { |doc| interesting_page doc }
        pages |= [interesting_files] unless interesting_files.empty?
      end
      Jekyll.logger.info "#{pages.length} pages were found in #{@site.source}."
      pages
    end

    def page_lookup_txt
      "#{@site.source}/_page_lookup.txt"
    end

    def page_lookup
      output = PageWithoutAFile.new(@site, @site.source, '', '_page_lookup.txt')
      output.content = File.exist?(page_lookup_txt) ? File.read(page_lookup_txt) : ''
      output.data["layout"] = nil
      output.data["static_files"] = static_files.map(&:to_liquid)
      output
    end
  end
end
