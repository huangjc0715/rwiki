#!/usr/bin/ruby -Ke

require 'drb'

class StaticFetcher

  def pagename_to_filename(name)
    name = name.gsub(/([^a-zA-Z0-9.-]+)/n) do
      '_' + $1.unpack('H2' * $1.size).join('_').upcase
    end
    sprintf("%s.html", name)
  end

  def initialize(rwiki, savedir='ruby-man-html')
    @rwiki = rwiki
    ref_name_proc = proc do |cmd, name, params|
      pagename_to_filename(name)
    end
    @env = {}
    @env['static_view'] = true
    @env['ref_name'] = @env['full_ref_name'] = :underline_html
    @savedir = savedir
  end

  def get_page(pagename)
    @rwiki.page(pagename)
  end

  def save(page, pagename=page.name, saved_pagenames={})
    if page.empty?
      STDERR.puts "warning: `#{pagename}' not found."
      return
    end
    filename = "#{@savedir}/#{pagename_to_filename(pagename)}"
    if saved_pagenames.key?(filename.downcase)
      STDERR.puts "warning: #{saved_pagenames[filename.downcase].dump} and #{filename.dump}"
    end
    saved_pagenames[filename.downcase] = filename
    File.open(filename, 'w') do |f|
      html = page.static_view_html(@env)
      f.write(html)
    end
    modified = page.modified
    File.utime(modified, modified, filename)
  end

  def collect_link_pages(pagename, pages)
    return [] if pages.key?(pagename)
    page = get_page(pagename)
    pages[pagename] = page
    link_pages = []
    page.hot_links.each do |link_pagename|
      link_pages.push(link_pagename)
    end
    page.hot_revlinks.each do |link_pagename|
      link_pages.push(link_pagename)
    end
    link_pages
  end

  def rec_save(top_pagename)
    top = get_page(top_pagename)
    if top.empty?
      STDERR.puts "error: `#{top_pagename}' not found."
      exit(false)
    end
    pages = {}
    lazy_list = [top_pagename]
    begin
      link_pages = lazy_list.collect do |pagename|
        collect_link_pages(pagename, pages)
      end
      link_pages.flatten!
      lazy_list = link_pages - pages.keys
    end until lazy_list.empty?
    saved_pagenames = {}
    pages.each do |pagename, page|
      save(page, pagename, saved_pagenames)
    end
    save(top, 'index', saved_pagenames)
  end
end

if __FILE__ == $0
  DRb.start_service("druby://localhost:0")
  rwiki_uri = ARGV.shift || "druby://localhost:7429" # ja/man
  #rwiki_uri = "druby://localhost:8725" # ja/install
  rwiki = DRbObject.new( nil, rwiki_uri )

  top_pagename = ARGV.shift || "Ruby\245\352\245\325\245\241\245\354\245\363\245\271\245\336\245\313\245\345\245\242\245\353"
  #top_pagename = "top"
  savedir = ARGV.shift || 'ruby-man-html'

  fetcher = StaticFetcher.new(rwiki, savedir)
  fetcher.rec_save(top_pagename)
end
