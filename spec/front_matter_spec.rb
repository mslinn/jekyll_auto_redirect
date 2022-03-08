# frozen_string_literal: true

require 'spec_helper'
fm_path = File.expand_path("../lib/jekyll/front_matter", __dir__)
require fm_path

describe(Jekyll::FrontMatterEditor) do
  let(:full_redirect) { ['redirect_from:', '- /old/path/page1.html'] }

  let(:redirect_page_only) { '- /old/path/page2.html' }

  let(:auto_redirect_id) { 'auto_redirect_id: ABCDEF1234567890' }
  let(:auto_redirect_id_no_value) { 'auto_redirect_id:' }

  let(:page_empty_matter) do
    <<~END_OF_PAGE
      ---
      ---
      Blah blah blah.
      Blah blah blah.
      Blah.
    END_OF_PAGE
  end

  let(:page_no_matter) do
    <<~END_OF_PAGE
      Blah blah blah.
      Blah blah blah.
      Blah.
    END_OF_PAGE
  end

  let(:page_virgin) do
    <<~END_OF_PAGE
      ---
      categories: [ Ruby ]
      date: 2022-03-06
      description: This is a description.
      last_modified_at: 2022-03-06
      layout: blog
      title: "This is a title with 'apostrophes'"
      ---
      <p>One upon a time...</p>
    END_OF_PAGE
  end

  let(:page_with_id_at_top) do
    <<~END_OF_PAGE
      ---
      auto_redirect_id: ABCDEF1234567890
      categories: [ Ruby ]
      date: 2022-03-06
      description: This is a description.
      last_modified_at: 2022-03-06
      layout: blog
      title: "This is a title with 'apostrophes'"
      ---
      <p>One upon a time...</p>
    END_OF_PAGE
  end

  let(:page_with_id_at_bottom) do
    <<~END_OF_PAGE
      ---
      categories: [ Ruby ]
      date: 2022-03-06
      description: This is a description.
      last_modified_at: 2022-03-06
      layout: blog
      title: "This is a title with 'apostrophes'"
      auto_redirect_id: ABCDEF1234567890
      ---
      <p>One upon a time...</p>
    END_OF_PAGE
  end

  let(:page_with_redirect_at_top) do
    <<~END_OF_PAGE
      ---
      redirect_from:
        - /old/path/myPage.html
      categories: [ Ruby ]
      date: 2022-03-06
      description: This is a description.
      last_modified_at: 2022-03-06
      layout: blog
      title: "This is a title with 'apostrophes'"
      ---
      <p>One upon a time...</p>
    END_OF_PAGE
  end

  let(:page_with_redirect_at_bottom) do
    <<~END_OF_PAGE
      ---
      categories: [ Ruby ]
      date: 2022-03-06
      description: This is a description.
      last_modified_at: 2022-03-06
      layout: blog
      title: "This is a title with 'apostrophes'"
      redirect_from:
        - /old/path/myPage.html
      ---
      <p>One upon a time...</p>
    END_OF_PAGE
  end

  let(:page_with_redirect_and_id) do
    <<~END_OF_PAGE
      ---
      categories: [ Ruby ]
      date: 2022-03-06
      description: This is a description.
      last_modified_at: 2022-03-06
      layout: blog
      title: This is a title
      auto_redirect_id: ABCDEF1234567890
      redirect_from:
        - /old/path/myPage.html
      ---
      <p>One upon a time...</p>
    END_OF_PAGE
  end

  it 'wags the dog' do
    array = [1, 2, 3, 4]
    expect(Jekyll.tail(array)).to eq(array[1..-1])
  end

  it 'finds index' do
    array = %w[Help I am trapped in this computer]
    expect(array.find_index { |line| line == 'trapped' }).to eq(3)
  end

  it 'handles empty matter' do
    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_empty_matter)
    expect(front_matter_editor.front_matter_end_index).to eq(0)
    expect(front_matter_editor.front_matter).to eq([])
  end

  it 'is virgin' do
    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_virgin)
    expect(front_matter_editor.front_matter).not_to include('auto_redirect_id:')
    expect(front_matter_editor.front_matter).not_to include('redirect_from:')
    expect(front_matter_editor.front_matter_end_index).to eq(6)
  end

  it 'it has auto_redirect_id and redirect' do
    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_with_redirect_and_id)
    expect(front_matter_editor.front_matter).to include(/auto_redirect_id:.*/)
    expect(front_matter_editor.front_matter).to include(/redirect_from:.*/)
  end

  it 'inserts auto_redirect_id into virgin page' do
    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_virgin)
    front_matter_editor.insert_into_front_matter(1, auto_redirect_id)
    # Jekyll.logger.info front_matter_editor.front_matter
    expect(front_matter_editor.front_matter_end_index).to eq(7)

    expect(front_matter_editor.front_matter).to include(auto_redirect_id)
    expect(front_matter_editor.auto_redirect_id).to eq('ABCDEF1234567890')
  end

  it 'variation inserts auto_redirect_id into virgin page' do
    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_virgin)
    front_matter_editor.insert_redirect('ABCDEF1234567890', '/previous/path.html')
    expect(front_matter_editor.front_matter).to include('  - /previous/path.html')
    expect(front_matter_editor.auto_redirect_id).to eq('ABCDEF1234567890')
  end

  it 'refuses to insert an auto_redirect_id into a page that already has one' do
    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_with_id_at_top)
    expect { front_matter_editor.insert_auto_redirect_id('asdf') }.to raise_error StandardError

    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_with_id_at_bottom)
    expect { front_matter_editor.insert_auto_redirect_id('asdf') }.to raise_error StandardError
  end

  it 'detects invalid auto_redirect_id' do
    front_matter_editor = Jekyll::FrontMatterEditor.new('/bogus/path/', page_virgin)
    front_matter_editor.insert_into_front_matter(1, auto_redirect_id_no_value)
    expect { front_matter_editor.auto_redirect_id }.to raise_error StandardError
  end
end
