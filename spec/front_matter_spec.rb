# frozen_string_literal: true

require 'spec_helper'

describe(Jekyll::JekyllAutoRedirect) do
  matter_virgin = <<-END_OF_FRONT_MATTER
    categories: [ Ruby ]
    date: 2022-03-06
    description: This is a description.
    last_modified_at: 2022-03-06
    layout: blog
    title: "This is a title with 'apostrophes'"
    END_OF_FRONT_MATTER

  let(:matter_with_id_at_top) do
    <<-END_OF_FRONT_MATTER
    auto_redirect_id: ABCDEF1234567890
    categories: [ Ruby ]
    date: 2022-03-06
    description: This is a description.
    last_modified_at: 2022-03-06
    layout: blog
    title: "This is a title with 'apostrophes'"
    END_OF_FRONT_MATTER
  end
  let(:matter_with_id_at_bottom) do
    <<-END_OF_FRONT_MATTER
    categories: [ Ruby ]
    date: 2022-03-06
    description: This is a description.
    last_modified_at: 2022-03-06
    layout: blog
    title: "This is a title with 'apostrophes'"
    auto_redirect_id: ABCDEF1234567890
    END_OF_FRONT_MATTER
  end
  let(:matter_with_redirect_at_top) do
    <<-END_OF_FRONT_MATTER
    redirect_from:
      - /old/path/myPage.html
    categories: [ Ruby ]
    date: 2022-03-06
    description: This is a description.
    last_modified_at: 2022-03-06
    layout: blog
    title: "This is a title with 'apostrophes'"
    END_OF_FRONT_MATTER
  end
  let(:matter_with_redirect_at_bottom) do
    <<-END_OF_FRONT_MATTER
    categories: [ Ruby ]
    date: 2022-03-06
    description: This is a description.
    last_modified_at: 2022-03-06
    layout: blog
    title: "This is a title with 'apostrophes'"
    redirect_from:
      - /old/path/myPage.html
    END_OF_FRONT_MATTER
  end
  let(:matter_with_redirect_and_id) do
    <<-END_OF_FRONT_MATTER
    categories: [ Ruby ]
    date: 2022-03-06
    description: This is a description.
    last_modified_at: 2022-03-06
    layout: blog
    title: "This is a title with 'apostrophes'"
    auto_redirect_id: ABCDEF1234567890
    redirect_from:
      - /old/path/myPage.html
    END_OF_FRONT_MATTER
  end

  before(:each) do
    # Need to figure this out
  end

  it 'is virgin' do
    contents = matter_virgin
    expect(contents).not_to include('auto_redirect_id:')
    expect(contents).not_to include('redirect_from:')
  end

  it 'it has id and redirect' do
    contents = matter_with_redirect_and_id
    expect(contents).to include('auto_redirect_id:')
    expect(contents).to include('redirect_from:')
  end
end
