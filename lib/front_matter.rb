require 'securerandom'

# Does not treat front matter as YAML because that would rewrite it, and probably changing it visually.
# Instead, parses front matter by brute force.
class FrontMatterEditor # rubocop:disable Metrics/ClassLength
  attr_reader :page_content_array

  # Analyze front matter
  # @param [string] path is relative path to page
  # @param [string] page_content is HTML content for that page
  def initialize(path, page_content)
    @path = path
    @page_content_array = page_content.split("\n")
    raise StandardError, "Page at #{@path} is empty" unless @page_content_array.length.positive?

    raise StandardError, "Page at #{@path} has no front matter" unless jekyll_page?

    front_matter_end_index.positive?
  end

  def self.tail(array)
    array.to_a[1..]
  end

  def jekyll_page?
    @page_content_array[0].start_with?('---')
  end

  # @return index of last line before the 2nd --- (Origin 0)
  def front_matter_end_index
    end_index = Jekyll.tail(@page_content_array)
                      .find_index { |line| line.start_with?('---') }
    raise StandardError, "Page at #{@path} is missing the second front matter delimiter" unless end_index

    end_index
  end

  # @return array sliced from @page_content_array containing front matter, exclusive of bounding --- lines.
  def front_matter
    @page_content_array[1..front_matter_end_index]
  end

  def auto_redirect_id
    line = front_matter.find { |x| x.start_with?('auto_redirect_id:') }
    return line unless line

    lines = line.split(':')
    return lines[1].strip if lines && lines.length == 2

    raise StandardError("Page at #{path} has an auto_redirect_id entry in its front matter, but there is no value") \
      if lines.length == 1

    nil
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
  def insert_into_front_matter(line_number, text)
    text = [text] unless text.is_a?(Array)
    text.each do |line|
      @page_content_array.insert(line_number, line)
      line_number += 1
    end
  end

  # @return UUID
  def insert_auto_redirect_id(auto_redirect_id = SecureRandom.uuid)
    raise StandardError, "Page at #{@path} already has an auto_redirect_id entry in its front matter" \
      if redirect_id_present

    insert_into_front_matter(1, "auto_redirect_id: #{auto_redirect_id}")
    auto_redirect_id
  end

  def insert_redirect(previous_path)
    next_line_number = next_redirect_index
    insert_into_front_matter(next_line_number, 'redirect_from:') unless redirect_key_present
    insert_into_front_matter(next_line_number + 1, "  - #{previous_path}")
  end

  # @return index to insert next redirect at, in @page_content_array.
  # If there is no redirect_from:, then return the index of the 2nd ---.
  # else return the index of the next unindented line.
  def next_redirect_index
    index = front_matter.find_index { |line| line.start_with? 'redirect_from:' }
    return front_matter_end_index + 1 if index.nil?

    next_key_index = front_matter[index..].find_index { |line| line.match(/^[[:alpha:]]+:/) }
    return next_key_index unless next_key_index.nil?

    front_matter_end_index
  end

  def redirect_values
    redirect_line = @page_content_array
                      .slice(0, front_matter_end_index)
                      .find_index { |line| line.start_with? 'redirect_from:' }
    values = []
    if redirect_line
      (redirect_line + 1..front_matter_end_index).each do |i|
        line = @page_content_array[i]
        return values unless line.start_with?("  - ")

        line.gsub!('  - ', '')
        values |= [line]
      end
    end
    values
  end

  private

  def redirect_key_present
    redirect_line = @page_content_array
                      .slice(0, front_matter_end_index)
                      .find_index { |line| line.start_with? 'redirect_from:' }
    !redirect_line.nil?
  end

  def redirect_id_present
    redirect_id_line = @page_content_array[0..front_matter_end_index]
                          .find_index { |line| line.start_with? 'auto_redirect_id:' }
    !redirect_id_line.nil?
  end
end
