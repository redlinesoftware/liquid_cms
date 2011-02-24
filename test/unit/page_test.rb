require File.expand_path('../../test_helper', __FILE__)

class Cms::PageTest < ActiveSupport::TestCase
  def setup
    ActionController::Base.module_eval do
      def request
        OpenStruct.new(:protocol => 'http://', :raw_host_with_port => 'test.com')
      end
    end
    @company = Factory(:company)
    @controller = ActionController::Base.new
  end

  context "data cleaning" do
    should "clean the slug value" do
      options = {:content => 'test'}
      page = @company.pages.create options.merge(:slug => 'test_page1')
      assert_equal '/test_page1', page.slug
      page = @company.pages.create options.merge(:slug => '/test_page2/')
      assert_equal '/test_page2', page.slug
      page = @company.pages.create options.merge(:slug => '/test_page3//')
      assert_equal '/test_page3', page.slug
      page = @company.pages.create options.merge(:slug => '//test_page4//')
      assert_equal '/test_page4', page.slug
    end
  end

  context "validations" do
    should "return blank errors" do
      page = @company.pages.create
      assert_equal 2, page.errors.length
      assert_equal "is invalid", page.errors[:name]
      assert_equal "can't be blank", page.errors[:content]

      page = @company.pages.create :published => true
      assert_equal 2, page.errors.length
      assert_equal "is invalid", page.errors[:name]
      assert_equal "can't be blank", page.errors[:content]
    end
    
    should "not allow duplicates" do
      # same company, duplicate fails
      page = @company.pages.create :name => @company.pages.first.name, :content => 'Test', :slug => @company.pages.first.slug
      assert_equal 2, page.errors.length
      assert_equal "has already been taken", page.errors[:name]
      assert_equal "has already been taken", page.errors[:slug]

      # multiple blank slugs can be saved
      page = @company.pages.create :name => 'new_name_1', :content => 'Test'
      assert page.errors.empty?
      page = @company.pages.create :name => 'new_name_2', :content => 'Test'
      assert page.errors.empty?

      # different company (scope), "duplicate" passes
      company = Company.create Factory.attributes_for(:company, :name => 'New Company', :domain_name => 'test.com', :subdomain => 'test')
      page = company.pages.create :name => @company.pages.first.name, :content => 'Test', :slug => @company.pages.first.slug
      assert_equal 0, page.errors.length
    end

    context "name" do
      should "check valid formats" do
        page = Factory(:page, :context => @company) 
        page.update_attributes :name => 'test_123'
        assert_nil page.errors.on(:name)
        page.update_attributes :name => 'test_123-test'
        assert_nil page.errors.on(:name)
        page.update_attributes :name => 'test_123-test/test'
        assert_not_nil page.errors.on(:name)
        page.update_attributes :name => 'test_123-test.test'
        assert_nil page.errors.on(:name)
      end
    end

    context "slugs" do
      setup do
        @options = {:name => 'Test', :content => 'Test'}
      end

      should "return correct content-types and url" do
        page = Factory(:page, :slug => nil, :context => @company)

        page.name = 'test.css'
        assert_equal 'text/css', page.content_type
        assert_equal '/cms/stylesheets/test.css', page.url
        page.name = 'test.js'
        assert_equal 'text/javascript', page.content_type
        assert_equal '/cms/javascripts/test.js', page.url
        page.name = 'test.json'
        assert_equal 'application/json', page.content_type
        assert_equal '/test.json', page.url
      end

      # should the slug be "cleaned" when assigned to via 'def slug='
      should "clean the slug when assigned"
=begin
        assert false
        page.name = 'test.html'
        assert_equal 'text/html', page.content_type
        page.name = 'test.somethingelse'
        assert_equal 'text/html', page.content_type
        page.name = 'test'
        assert_equal 'text/html', page.content_type
        page.name = 'cssjs'
        assert_equal 'text/html', page.content_type
=end

      should "allow multiple blank values when not published" do
        page = @company.pages.create @options.merge(:name => 'test1', :slug => nil, :published => false)
        assert page.valid?
        page = @company.pages.create @options.merge(:name => 'test2', :slug => nil, :published => false)
        assert page.valid?
      end

      should "reject any slugs that match namespaced controllers" do
        page = @company.pages.create @options.merge(:slug => '/cms')
        assert_equal 1, page.errors.length
        assert_equal "is reserved and can't be used for this page", page.errors[:slug]

        page = @company.pages.create @options.merge(:slug => '/cms')
        assert_equal 1, page.errors.length
        assert_equal "is reserved and can't be used for this page", page.errors[:slug]
      end
      
      should "reject a reserved name" do
        page = @company.pages.create @options.merge(:slug => '/cms/assets')
        assert_equal 1, page.errors.length
        assert_equal "is reserved and can't be used for this page", page.errors[:slug]
      end

      should "confirm reserved paths" do
        page = @company.pages.create :name => 'test'

        # reserved names
        %w(images stylesheets scripts stylesheets/test cms/pages cms/assets admin support cms/pages/test).each do |path|
          page.update_attributes :slug => "/#{path}"
          assert page.reserved_slug?, path
          page.update_attributes :slug => path
          assert page.reserved_slug?, path
        end

        # non-reserved names
        %w(test/stylesheets/test teststylesheets/test stylesheetstest/test).each do |path|
          page.update_attributes :slug => "/#{path}"
          assert !page.reserved_slug?
          page.update_attributes :slug => path
          assert !page.reserved_slug?
        end
      end
    end
  end

  context "page contents" do
    should "be identified as a layout file" do
      page = Factory(:page, :context => @company)
      page.content = <<-HTML
      <html>
        {{ content_for_layout }}
      </html>
      HTML
      assert page.is_layout_page?

      page.content = <<-HTML
      <html>
        {{content_for_layout}}
      </html>
      HTML
      assert page.is_layout_page?

      page.content = "{{content_for_layout}}"
      assert page.is_layout_page?

      page.content = <<-HTML
      <html>
        <p>test</p>
      </html>
      HTML
      assert !page.is_layout_page?
    end
  end

  context "layout page" do
    should "not be able to set publish or root flag" do
      page = Factory.build(:page, :context => @company, :slug => '/testpage', :published => true, :root => true, :content => "{{ content_for_layout }}")
      page.save
      %w(slug published root).each do |attr|
        assert_equal "can't be set for a layout page", page.errors.on(attr)
      end
    end
  end

  context "root flag" do
    should "only exist for one page" do
      curr_root = @company.pages.root
      assert_not_nil curr_root
      
      new_root = Factory(:page, :context => @company, :root => true)
      assert_not_equal curr_root, @company.pages.root
      assert_equal new_root, @company.pages.root
    end

    should "test #verify_single_root" do
      new_root = Factory(:page, :context => @company, :root => true)
      assert_equal new_root, @company.pages.root

      # saving the same page as root should keep the page as root
      new_root.update_attribute :root, true
      assert_equal new_root, @company.pages.root
    end
  end

  context "rendering" do
    should "render the page with no layout" do
      page = @company.pages.create :name => "Page without layout", :content => 'Test Page'
      assert_equal 'Test Page', page.rendered_content(@controller)
    end

    should "render the page with layout" do
      outer_layout = @company.pages.create :name => "outer_layout", :content => '<html><body>{{ content_for_layout }}</body></html>'
      inner_layout = @company.pages.create :name => "inner_layout", :content => '<div class="content">{{ content_for_layout }}</div>', :layout_page_id => outer_layout.id
      test_page = @company.pages.create :name => "test", :content => 'included content'
      page = @company.pages.create :name => "page_with_layout", :content => "Test Page {% include 'test' %}", :layout_page_id => inner_layout.id

      assert_equal '<html><body><div class="content">Test Page included content</div></body></html>', page.rendered_content(@controller)
    end

    should "render a stylesheet link" do
      @company.pages.create :name => 'test.css', :content => 'body{}'
      page = @company.pages.create :name => "page", :content => "{{ 'test.css' | page_url | stylesheet_tag }}"
      assert_equal '<link href="/cms/stylesheets/test.css" media="screen" rel="stylesheet" type="text/css" />', page.rendered_content(@controller)
    end

    should "render a javascript link" do
      @company.pages.create :name => 'test.js', :content => 'var test;'
      page = @company.pages.create :name => "page", :content => "{{ 'test.js' | page_url | script_tag }}"
      assert_equal '<script src="/cms/javascripts/test.js" type="text/javascript"></script>', page.rendered_content(@controller)
    end

    should "render a page link and a normal link" do
      page = @company.pages.create :name => "page", :content => "{{ 'home_page' | page_url | link_to }} {{ 'home_page' | page_url | link_to : 'text' }} {{ 'www.google.com' | link_to }} {{ 'www.google.com' | link_to : 'text' }}"
      assert_equal '<a href="/home_page">/home_page</a> <a href="/home_page">text</a> <a href="www.google.com">www.google.com</a> <a href="www.google.com">text</a>', page.rendered_content(@controller)
    end

    should "render a money value" do
      page = @company.pages.create :name => "page", :content => "{{ 75 | money }} {{ 75 | money: 2 }}"
      assert_equal '$75 $75.00', page.rendered_content(@controller)
    end
  end
end
