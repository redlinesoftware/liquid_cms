require File.expand_path('../../test_helper', __FILE__)

class Cms::PagesTest < ActionController::IntegrationTest

  def setup
    @company = Factory(:company)
    @user = @company.users.first
    login_company(@user.username, 'password')
    set_company_host(@company)

    stub_paperclip!
  end
  
  context "routes" do
    should "recognize routes" do
      assert_routing '/', :controller => 'cms/pages', :action => 'load'
      assert_routing '', :controller => 'cms/pages', :action => 'load'
    end
  end

  context "page title" do
    should "show the page title from a child template" do
      layout = Factory(:page, :slug => nil, :published => false, :content => read_fixture('layout.liquid'), :context => @company)
      page = Factory(:page, :name => 'content', :slug => "/content", :content => "<p>No title</p>", :layout_page => layout, :context => @company)

      get page.url
      assert_select 'title', 'Company Website'

      page.update_attribute :content, "{% assign title = 'Page Title' %}<p>Has Title</p>"
      get page.url
      assert_select 'title', 'Company Website - Page Title'

      page.update_attribute :content, "{% capture title %}{{ 'Captured Page' }} {{ 'Title' }}{% endcapture %}<p>Has Title</p>"
      get page.url
      assert_select 'title', 'Company Website - Captured Page Title'
    end
  end

  context "page loading" do
    context "root page" do
      should "load" do
        root = @company.pages.root
        assert_not_nil root

        get '/'
        assert_response :success
        assert_equal root, assigns(:page)
        assert_equal 'This is the home page', response.body

        get ''
        assert_response :success
        assert_equal root, assigns(:page)
        assert_equal 'This is the home page', response.body
      end

      should "render the first found published page if no root exists" do
        page = @company.pages.root
        page.update_attribute :root, false

        assert_nil @company.pages.root

        get '/'
        assert_response :success
        assert_equal assigns(:page), page

        get ''
        assert_response :success
        assert_equal assigns(:page), page
      end

      should "return an error if no root or published pages exist" do
        @company.pages.update_all :published => false, :root => false

        assert_nil @company.pages.root
        assert @company.pages.published.empty?

        assert_raises(ActionController::RoutingError) do
          get '/'
          assert_response 404
        end

        assert_raises(ActionController::RoutingError) do
          get ''
          assert_response 404
        end
      end

      should "load a cms page" do
        get 'home_page' 
        assert_response :success
        assert_equal 'text/html', @response.content_type
        assert_equal 'This is the home page', response.body

        # additional values can be added to a url to be used for more dyanmic pages
        get 'home_page/123' 
        assert_response :success
        assert_equal 'text/html', @response.content_type
        assert_equal 'This is the home page', response.body

        # if we create a new page with the previous slug, it gets called instead
        @company.pages.create :name => 'another_home', :slug => '/home_page/123', :content => 'Different Home', :published => true
        get 'home_page/123'
        assert_response :success
        assert_equal 'Different Home', response.body
      end
    end

    context "drops" do
      context "params" do
        should "not allow access to :controller and :action values" do
          @page = @company.pages.root
          @page.update_attribute :content, %Q(<span id="action">{{ params.action }}</span> <span id="controller">{{ params.controller }}</span> <span id="test">{{ params.test }}</span>)

          get '/?test=5'
          assert_select '#test', :text => '5'

          # action and controller aren't exposed
          assert_select '#action', :text => 'load', :count => 0
          assert_select '#controller', :text => 'pages', :count => 0
        end
      end
    end

    context "tags" do
      context "include" do
        should "show the contents of the included page" do
          @company.pages.create :name => 'content', :content => %Q(<h1>This is content</h1> <span>{{ param }}</span>)
          @page = @company.pages.root
          @page.update_attribute :content, %Q(<div id="content">{% include 'content' param:'test' %}</div>)
          get @page.url
          assert_select '#content h1', "This is content"
          assert_select '#content span', "test"
        end
      end

      context "asset_data" do
        should "find assets" do
          @asset = Factory(:image_asset, :context => @company, :custom_height => 200, :custom_width => 200)

          @page = @company.pages.create :name => 'content', :published => true, :content => <<-LIQUID
          {% asset_data %}
          LIQUID

          get @page.url
          assert response.body.include?("The required 'tag' parameter is missing.")

          @page.content = <<-LIQUID
          {% asset_data tag:'test' %}
          <span id="count">{{ assets | size }}</span>
          LIQUID
          @page.save

          get @page.url
          assert_select '#count', '0'

          # update the tags
          @asset.tag_list = "test"
          @asset.save

          @page.content = <<-LIQUID
          {% asset_data tag:'test' %}
          <span id="count">{{ assets | size }}</span>
          {{ assets | first | assign_to: 'meta_asset' }}
          <span class="o_dims">{{ meta_asset.image.original.width }}</span>
          <span class="c_dims">{{ meta_asset.image.custom.width }}</span>
          <span class="name">{{ meta_asset.meta.name_test }}</span>
          <span class="location">{{ meta_asset.meta.location }}</span>
          <span class="none">{{ meta_asset.meta.none }}</span>
          LIQUID
          @page.save

          get @page.url
          assert_select '#count', '1'
          assert_select '.o_dims', '20'
          assert_select '.c_dims', '20'
          assert_select '.name', ''
          assert_select '.location', ''
          assert_select '.none', ''

          # update the meta data
          @asset.meta_data = [{:name => 'name_test', :value => 'value test'}, {:name => 'location', :value => 'earth'}]
          @asset.save

          @page.content = <<-LIQUID
          {% asset_data tag:'test', as:'meta_assets' %}
          <span id="count">{{ meta_assets | size }}</span>
          {{ meta_assets | first | assign_to: 'meta_asset' }}
          <span class="name">{{ meta_asset.meta.name_test }}</span>
          <span class="location">{{ meta_asset.meta.location }}</span>
          <span class="none">{{ meta_asset.meta.none }}</span>
          LIQUID
          @page.save

          get @page.url
          assert_select '#count', '1'
          assert_select '.name', 'value test'
          assert_select '.location', 'earth'
          assert_select '.none', ''
        end
      end
    end
    
    context "filters" do
      setup do
        @page = @company.pages.root
      end

      context "assign_to" do
        should "assign data to a variable" do
          @page.update_attribute :content, %Q({{ 'data in a variable' | assign_to:'data' }}{{ data }})
          get @page.url
          assert_equal "data in a variable", response.body
        end
      end

      context "paginate_collection" do
        should "paginate the data" do
          # one user already exists, add 2 more
          assert_equal 1, @company.users.length
          Factory(:user, :company => @company)
          Factory(:user, :company => @company)

          @page.content = read_fixture('user_pagination.liquid')
          @page.save

          get @page.url
          assert_select '#all_users', '3'
          assert_select '#paginated_count_page_0', "Liquid syntax error: \"\" given as value, which translates to '0' as page number"
          assert_select '#paginate0_current_page', ''
          assert_select '#paginate0_next_page', ''
          assert_select '#paginated_count_page_1', '2' # 3 users, 2 on the first page, 2 per page
          assert_select '#paginate1_current_page', '1'
          assert_select '#paginate1_next_page', '2'
          assert_select '#paginated_count_page_2', '1' # 3 users, 1 on the second page, 2 per page
          assert_select '#paginate2_current_page', '2'
          assert_select '#paginate2_next_page', ''
        end
      end
      
      context "page_url" do
        should "throw an error" do
          @page.update_attribute :content, %Q({{ 'not found' | page_url }})
          get @page.url
          assert_equal "Liquid error: 'not found' page not found.", response.body
        end
      end
      
      context "asset_url" do
        should "throw an error" do
          @page.update_attribute :content, %Q({{ 'not found' | asset_url }})
          get @page.url
          assert_equal "Liquid error: 'not found' asset not found.", response.body
        end
      end

      context "component_url" do
        should "render a url" do
          @page.update_attribute :content, %Q({{ 'test' | component_url }})
          get @page.url
          assert_equal "/cms/components/#{@company.id}/test", response.body
        end
      end

      context "textilize" do
        should "convert text to html using textilize" do
          @page.update_attribute :content, %Q({% capture text %}test *this* string{% endcapture %}{{ text | textilize }})
          get @page.url
          assert_equal '<p>test <strong>this</strong> string</p>', response.body

          @page.update_attribute :content, %Q({% capture text %}test *this* string{% endcapture %}{{ text | textilize: false }})
          get @page.url
          assert_equal 'test <strong>this</strong> string', response.body
        end
      end

      context "image_tag" do
        should "show a title" do
          @page.update_attribute :content, %Q({{ 'test.jpg' | image_tag: "title" }})
          get @page.url
          assert_equal '<img alt="title" src="/images/test.jpg" title="title" />', response.body
        end

        should "show a title and size" do
          @page.update_attribute :content, %Q({{ 'test.jpg' | image_tag: "title", "23x45" }})
          get @page.url
          assert_equal '<img alt="title" height="45" src="/images/test.jpg" title="title" width="23" />', response.body
        end

        should "show just a size" do
          @page.update_attribute :content, %Q({{ 'test.jpg' | image_tag: nil, "23x45" }})
          get @page.url
          assert_equal '<img alt="Test" height="45" src="/images/test.jpg" width="23" />', response.body
        end

        should "render nothing" do
          @page.update_attribute :content, %Q({{ nil | image_tag: nil, "23x45" }})
          get @page.url
          assert_equal '', response.body
        end
      end

      context "url_encode and url_decode" do
        should "properly escape and unescape data" do
          @page.update_attributes :slug => '/path', :content => %Q(<span id="test">{{ 'test spaces' | url_encode }}</span><span id="first">{{ params.url[0] }}</span><span id="second">{{ params.url[1] | url_decode }}</span>)

          url = "#{@page.url}/#{CGI::escape 'test spaces'}"
          assert_equal url, "/path/test+spaces"
          get url
          assert_select '#test', 'test+spaces'
          assert_select '#first', 'path'
          assert_select '#second', 'test spaces'
        end

        should "handle an empty value" do
          @page.update_attributes :slug => '/path', :content => %Q(<span id="test">{{ nil | url_encode }}</span>)
          get @page.url
          assert_select '#test', ''
        end
      end

      context "liquified json data" do
        should "be valid for users" do
          @company.pages.create :name => 'test', :published => true, :content => "{% user_data %} {{ users | json }}"
          get '/test'

          # decode the json to access the data
          data = ActiveSupport::JSON.decode(@response.body)

          assert_equal data.length, @company.users.length
          assert_equal data[0]['user']['username'], 'user'
          assert_equal data[0]['user']['company_id'], @company.id
        end
      end
    end

    should "load a stylesheet page" do
      @company.pages.create :name => 'test.css', :content => 'body { color: white; }'
      get "/cms/stylesheets/test.css"
      assert_response :success
      assert_equal 'text/css', @response.content_type
      assert_equal 'body { color: white; }', @response.body
    end

    should "throw an exception if a page isn't found" do
      assert_raises(ActionController::RoutingError) do
        get '/home_page_not_found' 
        assert_response 404
      end
    end

    should "not load reserved paths for namespaced routes" do
      assert_raises(ActionController::RoutingError) do
        get '/support'
        assert_response 404
      end
    end

    should "not load an unknown path for reserved namespaces" do
      assert_raises(ActionController::RoutingError) do
        get '/cms/pages/unknown'
        assert_response 404
      end
    end
  end

=begin
  context "caching" do
    setup do
      ActionController::Base.perform_caching = true
      Rails.cache.clear
      @page = Factory(:page, :context => @company)
    end

    teardown do
      ActionController::Base.perform_caching = false
    end

    should "expire the cache when the page is updated" do
      assert_cache_empty

      get @page.url
      assert_cache_present

      # updating the page will remove the cache
      put cms_page_path(@page), :content => 'new content'
      assert_cache_empty

      get @page.url
      assert_cache_present

      # destroying the page will remove the cache
      delete cms_page_path(@page)
      assert_cache_empty
    end

    should "generate a cache key" do
      get '/'
      assert_cache_key "views/CONTEXT_PATH_#{@company.id}"

      get @page.url
      assert_cache_key "views/CONTEXT_PATH_#{@company.id}/page"

      get @page.url+'?page=1&test=abcde'
      assert_cache_key "views/CONTEXT_PATH_#{@company.id}/page/page=1&test=abcde"

      # different order sent via url, but the path params will be sorted in the path
      get @page.url+'?test=abcde&page=1'
      assert_cache_key "views/CONTEXT_PATH_#{@company.id}/page/page=1&test=abcde"
    end
  end
=end
end
