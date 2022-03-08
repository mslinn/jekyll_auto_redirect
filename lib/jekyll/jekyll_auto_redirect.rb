# frozen_string_literal: true

require 'fileutils'
require 'jekyll/front_matter'

module Jekyll
  # Generates /_auto_redirect.txt, which maps source paths to published URL paths
  class JekyllAutoRedirect < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(site)
      site.exclude |= ['_auto_redirect.txt']
      pages = assemble_pages(site)
      File.open(page_lookup_txt, 'w') do |file|
        pages.each do |page|
          if page.data.any? { |entry| entry =~ /^auto_redirect_id:.*/ }
            handle_moved(file, page)
          else
            insert_redirect_id(file, page)
          end
        end
      end
    end

    private

    def handle_moved(file, page)
      Jekyll.logger.info "TODO: write handle_moved"
    end

    def insert_redirect_id(file, page)
      content = File.read(page.path)
      front_matter_editor = Jekyll::FrontMatterEditor.new(page.path, content)
      auto_redirect_id = front_matter_editor.insert_auto_redirect_id
      file.puts "#{auto_redirect_id} #{page.url}"
      page.data << ['auto_redirect_id:', auto_redirect_id]
      Jekyll.logger.info "#{page.name}: added #{auto_redirect_id} for #{page.url}"
    end

    def interesting_page(page)
      ok = false
      if page.class.method_defined? :type
        ok = (page.type == :posts or page.type == :pages)
      elsif page.class.method_defined?(:html?)
        ok = page.html?
      end
      ok &&= page.base == @site.source if page.class.method_defined? :base
      ok &&= !page.relative_path.start_with?('_drafts')
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
      pages.flatten
    end

    def page_lookup_txt
      "#{@site.source}/_auto_redirect.txt"
    end

    def page_lookup
      output = PageWithoutAFile.new(@site, @site.source, '', '_auto_redirect.txt')
      output.content = File.exist?(page_lookup_txt) ? File.read(page_lookup_txt) : ''
      output.data["layout"] = nil
      output.data["static_files"] = static_files.map(&:to_liquid)
      output
    end
  end
end
