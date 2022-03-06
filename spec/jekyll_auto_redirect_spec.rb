# frozen_string_literal: true

require 'spec_helper'

describe(Jekyll::JekyllAutoRedirect) do
  let(:overrides) do
    {
      'source'      => source_dir,
      'destination' => dest_dir,
      'url'         => 'http://example.org',
      'collections' => {
        'my_collection' => { 'output' => true },
        'other_things'  => { 'output' => false },
      },
    }
  end
  let(:config) do
    Jekyll.configuration(overrides)
  end
  # puts "Running tests from #{Dir.pwd}"
  let(:site) { Jekyll::Site.new(config) }
  let(:contents) { File.read('_auto_redirect.txt') }
  before(:each) do
    site.process # Jekyll's entry point for reading, processing, and writing the Site to output.
  end

  it 'creates a _auto_redirect.txt file' do
    expect(File.exist?(dest_dir('_auto_redirect.txt'))).to be_truthy
  end

  it "doesn't have multiple new lines or trailing whitespace" do
    expect(contents).to_not match %r!\s+\n!
    expect(contents).to_not match %r!\n{2,}!
  end

  it 'puts all the pages in the _auto_redirect.txt file' do
    expect(contents).to match %r!<loc>http://example\.org/</loc>!
    expect(contents).to match %r!<loc>http://example\.org/some-subfolder/this-is-a-subpage\.html</loc>!
  end

  it "only strips 'index.html' from end of permalink" do
    expect(contents).to match %r!<loc>http://example\.org/some-subfolder/test_index\.html</loc>!
  end

  it 'puts all the posts in the _auto_redirect.txt file' do
    expect(contents).to match %r!<loc>http://example\.org/2014/03/04/march-the-fourth\.html</loc>!
    expect(contents).to match %r!<loc>http://example\.org/2014/03/02/march-the-second\.html</loc>!
    expect(contents).to match %r!<loc>http://example\.org/2013/12/12/dec-the-second\.html</loc>!
  end

  describe 'collections' do
    it 'puts all the `output:true` into _auto_redirect.txt' do
      expect(contents).to match %r!<loc>http://example\.org/my_collection/test\.html</loc>!
    end

    it "doesn't put all the `output:false` into _auto_redirect.txt" do
      expect(contents).to_not match %r!<loc>http://example\.org/other_things/test2\.html</loc>!
    end

    it "remove 'index.html' for directory custom permalinks" do
      expect(contents).to match %r!<loc>http://example\.org/permalink/</loc>!
    end

    it "doesn't remove filename for non-directory custom permalinks" do
      expect(contents).to match %r!<loc>http://example\.org/permalink/unique_name\.html</loc>!
    end

    it "performs URI encoding of site paths" do
      expect(contents).to match %r!<loc>http://example\.org/this%20url%20has%20an%20%C3%BCmlaut</loc>!
    end
  end

  it "puts all the static HTML files in the _auto_redirect.txt file" do
    expect(contents).to match %r!<loc>http://example\.org/some-subfolder/this-is-a-subfile\.html</loc>!
  end

  it "does not include assets or any static files that aren't .html" do
    expect(contents).not_to match %r!<loc>http://example\.org/images/hubot\.png</loc>!
    expect(contents).not_to match %r!<loc>http://example\.org/feeds/atom\.xml</loc>!
  end

  it "converts static index.html files to permalink version" do
    expect(contents).to match %r!<loc>http://example\.org/some-subfolder/</loc>!
  end

  it "does include assets or any static files with .xhtml and .htm extensions" do
    expect(contents).to match %r!/some-subfolder/xhtml\.xhtml!
    expect(contents).to match %r!/some-subfolder/htm\.htm!
  end

  it "does not include posts that have set 'sitemap: false'" do
    expect(contents).not_to match %r!/exclude-this-post\.html</loc>!
  end

  it "does not include pages that have set 'sitemap: false'" do
    expect(contents).not_to match %r!/exclude-this-page\.html</loc>!
  end

  it "does not include the 404 page" do
    expect(contents).not_to match %r!/404\.html</loc>!
  end

  it "includes the correct number of items" do
    # static_files/excluded.pdf is excluded on Jekyll 3.4.2 and above
    if Gem::Version.new(Jekyll::VERSION) >= Gem::Version.new("3.4.2")
      expect(contents.scan(%r!(?=<url>)!).count).to eql 21
    else
      expect(contents.scan(%r!(?=<url>)!).count).to eql 22
    end
  end
end
