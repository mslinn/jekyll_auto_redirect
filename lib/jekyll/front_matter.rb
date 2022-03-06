# frozen_string_literal: true

# rubocop:disable Layout/MultilineMethodCallIndentation
module Jekyll
  class FrontMatterEditor
    # Insert one or two lines into front matter, for example:
    # redirect_from:
    #   - /old/path/myPage.html
    # or
    # auto_redirect_id: ABCDEF1234567890
    def insert_redirect(lines, file_name_relative)
      lines_copy = Array.from(lines)
      lines_copy.shift
      new_text = "  - ${file_name_relative}"
      front_matter_end = lines_copy.findIndex(x => x.startsWith('---'))
      if redirect_value_present(lines_copy, front_matter_end, file_name_relative)
        Jekyll.logger.info "${file_name_relative} is already present in the list of redirect_from items"
      else
        next_line_number = next_redirect_index(lines_copy, front_matter_end)
        position = next_line_number
        insert(position, 'redirect_from:') if redirect_key_present(lines_copy, front_matter_end, file_name_relative)
        insert(position, "#{new_text}\n")
      end
    end

    # rubocop:disable Metrics/BlockNesting, Metrics/PerceivedComplexity, Style/For, Metrics/MethodLength
    def next_redirect_index(lines, front_matter_end)
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

    def redirect_key_present(lines, front_matter_end, file_name_relative)
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
