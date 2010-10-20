require File.dirname(__FILE__) + '/../test_helper'

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

    should "edit asset" do
      asset = Factory(:pdf_asset, :context => @company)
      assert_equal 'test.pdf', asset.asset_file_name

      new_asset_file = 'new_test.pdf'
      setup_asset new_asset_file

      put :update, :id => asset, :cms_asset => {:asset => ActionController::TestUploadedFile.new(asset_file(new_asset_file))}
      assert_response :redirect
      assert_redirected_to cms_root_path

      # check that the file name updated
      assert_equal new_asset_file, asset.reload.asset_file_name

      FileUtils.rm_rf TestConfig.paperclip_test_root
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

protected
  def setup_asset(file_name)
    FileUtils.mkdir_p asset_path
    FileUtils.touch asset_file(file_name)
  end

  def asset_path
    TestConfig.paperclip_test_root + '/assets'
  end

  def asset_file(file_name)
    asset_path + "/" + file_name
  end
end
