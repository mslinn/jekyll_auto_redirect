# frozen_string_literal: true

# rubocop:disable Layout/MultilineMethodCallIndentation
module Jekyll
  def self.tail(array)
    array.to_a[1..-1]
  end

  # Does not treat front matter as YAML because that would rewrite it, and probably changing it visually.
  # Instead, parses front matter by brute force.
  class FrontMatterEditor
    attr_reader :front_matter, :front_matter_end_index, :is_jekyll_page

    # Analyze front matter
    # @param [string] path is relative path to page
    # @param [string] page_content is HTML content for that page
    def initialize(path, page_content)
      @page_content_array = page_content.split("\n")
      raise StandardError, "Page at #{path} is empty" unless @page_content_array.length.positive?

      @is_jekyll_page = @page_content_array[0].start_with?('---')
      raise StandardError, "Page at #{path} has no front matter" unless @is_jekyll_page

      @front_matter_end_index =
        Jekyll.tail(@page_content_array)
              .find_index { |line| line.start_with?('---') }
      raise StandardError, "Page at #{path} is missing second front matter delimiter" unless @front_matter_end_index

      @front_matter = @page_content_array[1..@front_matter_end_index]
    end

    def auto_redirect_id
      line = @front_matter.find(x => x.startsWith('auto_redirect_id:'))
      return line unless line

      lines = line.split(':')
      return lines[1].trim if lines && len(lines) == 2

      raise StandardError("Page at #{path} has an auto_redirect_id entry in its front matter, but there is no value")
    end

    # Insert one or more lines into front matter, for example:
    # redirect_from:
    #   - /old/path/myPage.html
    #
    # or
    #
    # auto_redirect_id: ABCDEF1234567890
    #
    # @param line_number [int] index of @page_content_array to start inserting at, origin 0
    # @param text [Array | string] content to be inserted
    def insert(line_number, text)
      text = [text] unless text.is_a?(Array) # rubocop:disable Style/ArrayCoercion
      text.each do |line|
        @page_content_array.insert(line_number, line)
        line_number += 1;
      end
    end

    def insert_redirect(file_name_relative)
      if redirect_value_present(file_name_relative)
        Jekyll.logger.info "${file_name_relative} is already present in the list of redirect_from items"
      else
        next_line_number = next_redirect_index
        insert(next_line_number, 'redirect_from:') unless redirect_key_present
        next_line_number += 1;
        insert(next_line_number, "#{file_name_relative}\n")
      end
    end

    # rubocop:disable Metrics/BlockNesting, Metrics/PerceivedComplexity, Style/For, Metrics/MethodLength
    def next_redirect_index
      last_redirect_index = -1
      processing_redirects = false
      found_redirect_from = false
      if front_matter_end >= 0
        for i in 0..front_matter_end
          if lines[i].start_with?('redirect_from:')
            last_redirect_index = i
            found_redirect_from = true
            processing_redirects = true
          elsif processing_redirects
            if lines[i].start_with?('  - ')
              last_redirect_index = i
            else
              processing_redirects = false
            end
          end
        end
        return front_matter_end + 1 unless found_redirect_from

        return last_redirect_index + 2
      end
      -1
    end

    private

    def redirect_key_present
      redirect_line = lines
                       .slice(0, front_matter_end)
                       .findIndex { |line| line.start_with? 'redirect_from:' }
      redirect_line > -1
    end

    def redirect_value_present(lines, front_matter_end, file_name_relative)
      redirect_line = lines
                        .slice(0, front_matter_end)
                        .findIndex { |line| line.start_with? 'redirect_from:' }
      if redirect_line>=0
        for i in redirect_line + 1..front_matter_end do
          line = lines[i]
          return false unless line.start_with("  - ")

          file_name = line.replace('  - ', '')
          return true if file_name == file_name_relative
        end
      end
      false
    end
  end
end
# rubocop:enable Layout/MultilineMethodCallIndentation
