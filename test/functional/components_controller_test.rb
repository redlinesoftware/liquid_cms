require File.dirname(__FILE__) + '/../test_helper'

class Cms::ComponentsControllerTest < ActionController::TestCase
  def setup
    setup_company_and_login_admin
  end

  should "add component tests"
end
