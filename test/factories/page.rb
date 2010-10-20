Factory.define :page, :class => Cms::Page do |p|
  p.name "page"
  p.slug '/page'
  p.root false
  p.content 'This is a page'
  p.published true
  p.layout_page nil
end

Factory.define :home_page, :class => Cms::Page do |p|
  p.name "home_page"
  p.slug '/home_page'
  p.root true
  p.content 'This is the home page'
  p.published true
end
