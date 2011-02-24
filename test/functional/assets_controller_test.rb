require File.expand_path('../../test_helper', __FILE__)

class Cms::AssetsControllerTest < ActionController::TestCase

  def setup
    setup_company_and_login_admin
  end

  context "actions" do
    should "show the image asset" do
      asset = Factory(:image_asset, :context => @company)
      get :show, :id => asset
      assert_response :success
      assert_select '#content img'
      assert_select 'p', :text => /Open/, :count => 0
      assert_select 'p', /Filesize/
      assert_select 'p', /Last Updated/
    end

    should "show the non-image asset" do
      asset = Factory(:pdf_asset, :context => @company)
      get :show, :id => asset
      assert_response :success
      assert_select '#content img', false
      assert_select 'p', :text => /Open/, :count => 1
      assert_select 'p', /Filesize/
      assert_select 'p', /Last Updated/
    end

    context "edit" do
      should "upload a new asset file" do
        asset = Factory(:pdf_asset, :context => @company)
        assert_equal 'test.pdf', asset.asset_file_name

        new_asset_file = asset_file('new_test.pdf')
        setup_asset new_asset_file

        put :update, :id => asset, :cms_asset => {:asset => fixture_file_upload(File.join(ASSET_PATH, new_asset_file))}
        assert_response :redirect
        assert_redirected_to cms_root_path

        # check that the file name updated
        assert_equal File.basename(new_asset_file), asset.reload.asset_file_name

        cleanup_assets
      end

      should "modify the contents of an editable asset file"
      should "modify the contents of an non-editable asset file"
    end

    should "destroy asset via HTML :DELETE" do
      asset = Factory(:pdf_asset, :context => @company)
      assert_not_nil @company.assets.find_by_id(asset.id)

      delete :destroy, :id => asset
      assert_response :redirect
      assert_redirected_to cms_root_path
      assert_nil @company.assets.find_by_id(asset.id)
    end

    should "destroy asset via XHR :DELETE" do
      asset = Factory(:pdf_asset, :context => @company)
      assert_not_nil @company.assets.find_by_id(asset.id)

      xhr :delete, :destroy, :id => asset
      assert_response :success
      assert_nil @company.assets.find_by_id(asset.id)
    end
  end
end
