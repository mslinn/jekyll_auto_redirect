require_relative './front_matter'

class AutoSite
  attr_reader :auto_redirect_txt, :config, :pages, :redirects, :site

  def initialize(config, site)
    @auto_redirect_txt = "#{site.source}/_auto_redirect.txt"
    @config = config
    @redirects = auto_redirects
    @site = site
    @pages = @site.pages
  end

  # @return map of id: path
  def auto_redirects
    hash = {}
    return hash unless File.exist? @auto_redirect_txt

    File.readlines(@auto_redirect_txt, chomp: true).each do |line|
      hash.merge!(Hash[*line.split]) if line.include? ' '
    end
  end
end
