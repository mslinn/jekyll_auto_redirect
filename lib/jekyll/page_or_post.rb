# frozen_string_literal: true

require 'jekyll/front_matter'

module Jekyll
  class PageOrPost
    attr_reader :auto_redirect_id, :auto_site, :content, :front_matter_editor

    def initialize(site, page)
      @auto_site = AutoSite.new(site)
      @page = page

      @content = File.read(@page.path)
      @front_matter_editor = Jekyll::FrontMatterEditor.new(@page.path, @content)
      @auto_redirect_id = @front_matter_editor.auto_redirect_id
    end

    def generate_page(file)
      if @auto_redirect_id
        page_moved?(@page) { |previous_path| @front_matter_editor.insert_redirect(previous_path) }
        @redirect_array.except! @auto_redirect_id
      else
        insert_redirect_id
      end
      file.puts "#{@auto_redirect_id} #{@page.url}"
    end

    # @return the page's old path if the page moved, otherwise return nil
    def page_moved?
      id = @front_matter_editor.auto_redirect_id
      old_path = @redirect_array[id]
      return old_path unless @page.path == old_path

      nil
    rescue IndexError
      raise IndexError, "Page #{id} was not found in #{@auto_site.auto_redirect_txt}"
    end

    def insert_redirect_id
      auto_redirect_id = @front_matter_editor.insert_auto_redirect_id
      @page.data << ['auto_redirect_id:', auto_redirect_id]
      Jekyll.logger.info "#{@page.name}: added #{auto_redirect_id} for #{@page.url}"
    end

    private

    def interesting_page
      ok = false
      if @page.class.method_defined? :type
        ok = (@page.type == :posts or @page.type == :pages)
      elsif @page.class.method_defined?(:html?)
        ok = @page.html?
      end
      ok &&= @page.base == @auto_site.site.source if @page.class.method_defined? :base
      ok &&= !@page.relative_path.start_with?('_drafts')
      ok
    end
  end
end
