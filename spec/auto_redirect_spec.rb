# frozen_string_literal: true

require 'jekyll'
require 'fileutils'
require_relative "../lib/jekyll_auto_redirect"

RSpec.describe(Jekyll::JekyllAutoRedirect) do
  let(:config) { instance_double("Configuration") }

  let(:site) do
    site_ = instance_double("Site")
    allow(site_).to receive(:source) { Dir.pwd }
    allow(site_).to receive(:config) { config }
    allow(site_).to receive(:pages) { [page1] }
    site_
  end

  let(:auto_site) do
    site_ = site
    auto_site_ = instance_double("AutoSite")
    allow(auto_site_).to receive(:auto_redirect_txt) { "#{site_.source}/_auto_redirect.txt" }
    allow(auto_site_).to receive(:auto_redirects) { [] }
    allow(auto_site_).to receive(:config) { config }
    allow(auto_site_).to receive(:pages) { site_.pages }
    allow(auto_site_).to receive(:redirect) { [] }
    allow(auto_site_).to receive(:site) { site_ }
    auto_site_
  end

  let(:page) do
    page_ = instance_double("Page")
    allow(page_).to receive(:path) { 'bogus/path' }
    allow(page_).to receive(:data) { {} }
    page_
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

  let(:page1) do
    Jekyll::PageOrPost.new(config, auto_site, page)
  end

  it 'exercises mocks' do
    expect { config }
  end

  it 'detects a page being moved' do
    expect(config).not_to be_nil
    expect(page).not_to be_nil
    expect(auto_site).not_to be_nil

    expect(page1.moved?).to be_true
  end
end
