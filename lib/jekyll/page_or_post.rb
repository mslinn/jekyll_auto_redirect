# frozen_string_literal: true

require_relative './front_matter'

module Jekyll
  class PageOrPost
    attr_reader :auto_site, :content, :front_matter_editor

    def initialize(config, auto_site, page)
      @config = config
      @auto_site = auto_site
      @page = page

      unless @page.class.instance_methods.include? :path
        error { "Error: Jekyll::PageOrPosts.initialize did not find a :path for #{@page}" }
      end
      @content = File.read(@page.path)
      @front_matter_editor = Jekyll::FrontMatterEditor.new(@page.path, @content)
    end

    def auto_redirect_id
      @front_matter_editor.auto_redirect_id
    end

    def generate_page(file)
      if auto_redirect_id
        moved? do |previous_path|
          @front_matter_editor.insert_redirect(previous_path)
        end
        # @redirect_array.except! auto_redirect_id
      else
        insert_redirect_id
        write_modified_page
      end

      id = @page.data['auto_redirect_id']
      if id
        file.puts "#{id} #{@page.url}"
      else
        warn { "Warning: Jekyll::PageOrPosts.generate_page did not obtain auto_redirect_id for #{@page.url}, this entry was not written to _auto_redirect.txt" }
      end
    end

    # @return the page's old path if the page moved, otherwise return nil
    def moved?
      id = @front_matter_editor.auto_redirect_id
      unless @front_matter_editor.redirect_values.include? @page.path
        old_path = @auto_site.redirects[id]
        return nil unless old_path
        return old_path unless @page.path == old_path
      end
      nil
    end

    def insert_redirect_id
      auto_redirect_id = @front_matter_editor.insert_auto_redirect_id
      @page.data['auto_redirect_id'] = auto_redirect_id
    end

    def write_modified_page
      content = @front_matter_editor.page_content_array.join "\n"
      File.write(@page.path, content)
    end
  end
end
