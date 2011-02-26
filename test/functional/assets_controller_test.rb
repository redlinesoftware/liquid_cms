require File.dirname(__FILE__) + '/../test_helper'

class Cms::AssetsControllerTest < ActionController::TestCase

  def setup
    setup_company_and_login_admin
  end

  context "actions" do
    context "new" do
      should "show the new form" do
        get :new
        assert_select 'div.text', false
        assert_select 'div.file .hint', 'Upload an asset file.'
      end
    end

    context "show" do
      should "show an image asset" do
        asset = Factory(:image_asset, :context => @company)
        get :show, :id => asset
        assert_response :success
        assert_select '#content img'
        assert_select 'p', :text => /Open/, :count => 0
        assert_select 'p', /Filesize/
        assert_select 'p', /Last Updated/
      end

      should "show a non-image asset" do
        asset = Factory(:pdf_asset, :context => @company)
        get :show, :id => asset
        assert_response :success
        assert_select '#content img', false
        assert_select 'p', :text => /Open/, :count => 1
        assert_select 'p', /Filesize/
        assert_select 'p', /Last Updated/
      end
    end

    context "edit" do
      should "show form for an editable asset with a textarea" do
        Cms::Asset.any_instance.stubs(:asset).returns(stub(:to_file => stub(:read => 'test contents')))
        asset = Factory(:js_asset, :context => @company)

        get :edit, :id => asset.id
        assert_select 'div.text', true
        assert_select 'p.break', :text => 'or edit the contents...', :count => 1
        assert_select 'div.file .hint', 'An existing file has been uploaded.  Upload a new file to replace it.'
      end

      should "show form for an editable asset without a textarea" do
        asset = Factory(:pdf_asset, :context => @company)

        get :edit, :id => asset.id
        assert_select 'div.text', false
        assert_select 'p.break', :text => 'or edit the contents...', :count => 0
        assert_select 'div.file .hint', 'An existing file has been uploaded.  Upload a new file to replace it.'
      end
    end

    context "update" do
      teardown do
        cleanup_assets
      end

      should "upload a new asset file" do
        asset = Factory(:pdf_asset, :context => @company)
        assert_equal 'test.pdf', asset.asset_file_name

        new_asset_file = asset_file('new_test.pdf')
        setup_asset new_asset_file

        put :update, :id => asset, :cms_asset => {:asset => ActionController::TestUploadedFile.new(new_asset_file)}
        assert_response :redirect
        assert_redirected_to cms_root_path

        # check that the file name updated
        assert_equal File.basename(new_asset_file), asset.reload.asset_file_name
      end

      should "modify the contents of an editable asset file" do
        asset = Factory(:pdf_asset, :context => @company)
        put :update, :id => asset, :file_content => 'new content'
        assert_response :success
        assert_template 'edit'
      end

      should "modify the contents of an non-editable asset file" do
        asset = Factory(:js_asset, :context => @company)

        asset_file = asset_file(asset.asset_file_name)
        setup_asset asset_file

        Cms::Asset.any_instance.stubs(:asset => stub(:path => asset_file))
        Cms::Asset.any_instance.expects(:write).with('new content').returns(true)

        put :update, :id => asset, :file_content => 'new content'
        assert_response :redirect
      end
    end

    context "destroy" do
      setup do
        @asset = Factory(:pdf_asset, :context => @company)
      end

      should "destroy asset via HTML :DELETE" do
        assert_not_nil @company.assets.find_by_id(@asset.id)

        delete :destroy, :id => @asset
        assert_response :redirect
        assert_redirected_to cms_root_path
        assert_nil @company.assets.find_by_id(@asset.id)
      end

      should "destroy asset via XHR :DELETE" do
        assert_not_nil @company.assets.find_by_id(@asset.id)

        xhr :delete, :destroy, :id => @asset
        assert_response :success
        assert_nil @company.assets.find_by_id(@asset.id)
      end
    end
  end
end
