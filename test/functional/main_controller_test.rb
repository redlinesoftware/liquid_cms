require File.expand_path('../../test_helper', __FILE__)

class Cms::MainControllerTest < ActionController::TestCase

  def setup
    setup_company_and_login_admin
  end

  context "asset list" do
    should "show thumbnail and show page for image assets and direct link for non-image assets" do
      img_asset = Factory(:image_asset, :context => @company)
      pdf_asset = Factory(:pdf_asset, :context => @company)

      get :index
      assert_response :success
      assert_select "#assets p.preview", true
      assert_select "li#cms_asset_#{img_asset.id} a", img_asset.asset_file_name
      assert_select "li#cms_asset_#{img_asset.id} div.asset_image"
      assert_select "li#cms_asset_#{pdf_asset.id} a", pdf_asset.asset_file_name
      assert_select "li#cms_asset_#{pdf_asset.id} div.asset_image", false
    end

    should "not should the preview link if no images have been uploaded" do
      pdf_asset = Factory(:pdf_asset, :context => @company)

      get :index
      assert_response :success
      assert_select "#assets p.preview", false
    end
  end

  context "permission access" do
    setup do
      logout_user
    end

    should "redirect to the login screen" do
      get :index
      assert_response :redirect
      assert_redirected_to '/login'
    end
  end
end
