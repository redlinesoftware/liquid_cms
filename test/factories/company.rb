Factory.define :company do |c|
  c.name "Test"
  c.domain_name 'acme.com'
  c.subdomain 'test'
  c.after_create do |c|
    Factory(:home_page, Cms.context_class ? {:context => c} : {})
  end
  c.after_create do |c|
    Factory(:user, :company => c)
  end
end
