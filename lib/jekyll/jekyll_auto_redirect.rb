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
      @auto_redirect_array = auto_redirect_array
      File.open(auto_redirect_txt, 'w') do |file|
        pages.each { |page| generate_page(file, page) }
      end
      # TODO process remaining items in @auto_redirect_array; they are deleted pages and posts
    end

    private

    def generate_page(file, page)
      @content = File.read(page.path)
      @front_matter_editor = Jekyll::FrontMatterEditor.new(page.path, @content)
      auto_redirect_id = @front_matter_editor.auto_redirect_id
      if auto_redirect_id
        page_moved?(page) { |previous_path| @front_matter_editor.insert_redirect(previous_path) }
        @auto_redirect_array.except! auto_redirect_id
      else
        insert_redirect_id page
      end
      file.puts "#{auto_redirect_id} #{page.url}"
    end

    # @return the page's  old path if the page moved, otherwise return nil
    def page_moved?(page)
      id = @front_matter_editor.auto_redirect_id
      old_path = @auto_redirect_array[id]
      return old_path unless page.path == old_path

      nil
    rescue IndexError
      raise IndexError, "Page #{id} was not found in #{auto_redirect_txt}"
    end

    def insert_redirect_id(page)
      auto_redirect_id = @front_matter_editor.insert_auto_redirect_id
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

    def auto_redirect_txt
      "#{@site.source}/_auto_redirect.txt"
    end

    def auto_redirect_array
      return IO.readlines(auto_redirect_txt, chomp => true) if File.exist? auto_redirect_txt

      []
    end
  end
end
