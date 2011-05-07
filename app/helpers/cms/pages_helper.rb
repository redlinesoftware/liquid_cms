module Cms::PagesHelper
  def layouts_for_page(page)
    page.new_record? ? @context.pages.layouts : @context.pages.layouts.reject{|pg| pg == page}
  end

  # find the # of term matches in each page and sorts the pages by the match count (highest to lowest)
  # only shows the first SEARCH_LIMIT pages
  def page_match_order(pages, term)
    pages.collect{|page| [page, page.content.scan(/#{term}/i).length]}.sort{|a,b| b[1] <=> a[1]}[0..(Cms::PagesController::SEARCH_LIMIT-1)]
  end
end
