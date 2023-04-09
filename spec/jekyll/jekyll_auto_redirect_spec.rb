require 'jekyll'
require 'fileutils'
require_relative '../lib/jekyll_auto_redirect'
require_relative 'spec_helper'

RSpec.describe(Jekyll::JekyllAutoRedirect) do
  let(:config) { instance_double(Configuration) }

  let(:site) do
    site_ = instance_double(Site)
    allow(site_).to receive(:source) { Dir.pwd }
    allow(site_).to receive(:config) { config }
    allow(site_).to receive(:pages) { [page1] }
    site_
  end

  let(:auto_site) do
    site_ = site
    auto_site_ = instance_double(AutoSite)
    allow(auto_site_).to receive(:auto_redirect_txt) { "#{site_.source}/_auto_redirect.txt" }
    allow(auto_site_).to receive(:auto_redirects).and_return []
    allow(auto_site_).to receive(:config) { config }
    allow(auto_site_).to receive(:pages) { site_.pages }
    allow(auto_site_).to receive(:redirects).and_return({})
    allow(auto_site_).to receive(:site) { site_ }
    auto_site_
  end

  let(:page) do
    page_ = instance_double(Page)
    allow(page_).to receive(:path).and_return 'spec/fixtures/test_moved.html'
    allow(page_).to receive(:data).and_return(
      {
        auto_redirect_id: '012345',
        redirect_from:    ['/old/path/myPage.html'],
      }
    )
    page_
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

    expect(page1.moved?).to be_nil

    allow(auto_site).to receive(:redirects).and_return({ '012345': 'new/path/to/page.html' })
    expect(page1.moved?).to eq 'new/path/to/page.html'
  end
end
