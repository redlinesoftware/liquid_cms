require File.expand_path('../../test_helper', __FILE__)

class Cms::ComponentsControllerTest < ActionController::TestCase
  def setup
    setup_company_and_login_admin
  end

  should "add component tests"
end
