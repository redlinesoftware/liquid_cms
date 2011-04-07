require File.expand_path('../../no_context_test_helper', __FILE__)
require File.expand_path('../../test_helpers/cache_helper', __FILE__)

class Cms::PagesTestNoContext < ActionController::IntegrationTest

  def setup
    @company = Factory(:company)
    @user = @company.users.first
    login_company(@user.username, 'password')
    set_company_host(@company)
  end

  context "caching" do
    setup do
      ActionController::Base.perform_caching = true
      Rails.cache.clear
      @page = Factory(:page)
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
      assert_cache_key "views/NO_CONTEXT"

      get @page.url
      assert_cache_key "views/NO_CONTEXT/page"

      get @page.url+'?page=1&test=abcde'
      assert_cache_key "views/NO_CONTEXT/page/page=1&test=abcde"

      # different order sent via url, but the path params will be sorted in the path
      get @page.url+'?test=abcde&page=1'
      assert_cache_key "views/NO_CONTEXT/page/page=1&test=abcde"
    end
  end
end
