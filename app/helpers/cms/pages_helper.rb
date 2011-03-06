module Cms::PagesHelper
  def layouts_for_page(page)
    page.new_record? ? @context.pages.layouts : @context.pages.layouts.reject{|pg| pg == page}
  end

  def delete_page_link(page)
    options = {:method => :delete, :confirm => "Are you sure you want to delete the \"#{page}\" page?"}
  
    # use a remote link if there are no children since if we remove the current page list item, all the children items get removed (in the UI) as well
    # it's easier to just remove the item otherwise with a normal post and refresh the page
    if page.content_pages.empty?
      link_to cms_icon('delete.png', :title => 'Delete'), cms_page_path(page), {:remote => true, :indicator => dom_id(page, 'progress')}.merge(options)
    else
      link_to cms_icon('delete.png', :title => 'Delete'), cms_page_path(page), options
    end
  end

  # find the # of term matches in each page and sorts the pages by the match count (highest to lowest)
  # only shows the first SEARCH_LIMIT pages
  def page_match_order(pages, term)
    pages.collect{|page| [page, page.content.scan(/#{term}/i).length]}.sort{|a,b| b[1] <=> a[1]}[0..(Cms::PagesController::SEARCH_LIMIT-1)]
  end
end
