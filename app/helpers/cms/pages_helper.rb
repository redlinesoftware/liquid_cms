module Cms::PagesHelper
  def layouts_for_page(page)
    page.new_record? ? @context.pages.layouts : @context.pages.layouts.reject{|pg| pg == page}
  end

  def delete_page_link(page)
    options = {:method => :delete, :confirm => "Are you sure you want to delete the \"#{page}\" page?"}
  
    # use a remote link if there are no children since if we remove the current page list item, all the children items get removed (in the UI) as well
    # it's easier to just remove the item otherwise with a normal post and refresh the page
    if page.content_pages.empty?
      link_to_remote cms_icon('delete.png', :title => 'Delete'), {:url => cms_page_path(page), :indicator => dom_id(page, 'progress')}.merge(options)
    else
      link_to cms_icon('delete.png', :title => 'Delete'), cms_page_path(page), options
    end
  end
end
