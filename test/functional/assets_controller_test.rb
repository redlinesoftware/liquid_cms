require File.expand_path('../../test_helper', __FILE__)

class Cms::AssetsControllerTest < ActionController::TestCase

  def setup
    setup_company_and_login_admin
  end

  context "actions" do
    context "new" do
      should "show the new form" do
        get :new
        assert_select 'div.text', false
        #assert_select 'div.file .hint', 'Upload an asset file.'
      end

      should "populate the new asset with tag and meta details" do
        asset = Factory(:image_asset, :context => @company, :tag_list => 'test', :meta_data => [{:name => 'field1', :value => 'test1'}, {:name => 'field2', :value => 'test2'}], :custom_width => 200, :custom_height => 100)
        get :new, :tag => asset.tag_list.to_s
        assert_response :success

        new_asset = assigns(:asset)
        assert_equal 'test', new_asset.tag_list.to_s
        assert_equal 2, new_asset.meta_data.length
        # values are removed from new assets
        assert_equal 'field1', new_asset.meta_data[0][:name]
        assert_equal '', new_asset.meta_data[0][:value]
        assert_equal 'field2', new_asset.meta_data[1][:name]
        assert_equal '', new_asset.meta_data[1][:value]
        assert_equal 200, new_asset.custom_width
        assert_equal 100, new_asset.custom_height

        assert_select '#meta_fields li', new_asset.meta_data.length
      end

      should "not populate the new asset with tag and meta details" do
        asset = Factory(:image_asset, :context => @company, :tag_list => 'test', :meta_data => [{:name => 'field1', :value => 'test1'}, {:name => 'field2', :value => 'test2'}])
        get :new, :tag => 'unknown'
        assert_response :success

        new_asset = assigns(:asset)
        assert_equal 'unknown', new_asset.tag_list.to_s
        assert_nil new_asset.meta_data
      end
    end

    context "create" do
      teardown do
        cleanup_assets
      end

      should "create an asset" do
        asset_file = asset_file('new_test.pdf')
        setup_asset asset_file

        post :create, :cms_asset => {:asset => fixture_file_upload(File.join('assets', File.basename(asset_file))), :meta => {'new_0' => {:name => 'key_a', :value => 'test'}, 'new_1' => {:name => 'key_b', :value => 'test'}} }
        assert_response :redirect
        assert_redirected_to cms_root_path

        asset = assigns(:asset)
        assert_equal 2, asset.meta_data.length
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
        Cms::Asset.any_instance.stubs(:asset).returns(stub(:url => 'test.com', :to_file => stub(:read => 'test contents')))
        asset = Factory(:js_asset, :context => @company)

        get :edit, :id => asset.id
        assert_select 'div.text', true
        assert_select 'p.break', :text => 'or edit the contents...', :count => 1
        #assert_select 'div.file .hint', 'An existing file has been uploaded.  Upload a new file to replace it.'
      end

      should "show form for an editable asset without a textarea" do
        asset = Factory(:pdf_asset, :context => @company)

        get :edit, :id => asset.id
        assert_select 'div.text', false
        assert_select 'p.break', :text => 'or edit the contents...', :count => 0
        #assert_select 'div.file .hint', 'An existing file has been uploaded.  Upload a new file to replace it.'
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

        put :update, :id => asset, :cms_asset => {:asset => fixture_file_upload(File.join('assets', File.basename(new_asset_file)))}
        assert_response :redirect
        assert_redirected_to edit_cms_asset_path(asset)
        assert_equal 'The asset has been updated.', flash[:notice]

        # check that the file name updated
        assert_equal File.basename(new_asset_file), asset.reload.asset_file_name
      end

      should "modify the contents of a non-editable asset file" do
        asset = Factory(:pdf_asset, :context => @company)

        # file contents are ignored for non-editable assets
        put :update, :id => asset, :cms_asset => {:file_content => 'new content'}
        assert_response :redirect
        assert_redirected_to edit_cms_asset_path(asset)
        assert_equal 'The asset has been updated.', flash[:notice]
      end

      context "update editable content" do
        setup do
          @asset = Factory(:js_asset, :context => @company)

          asset_file = asset_file(@asset.asset_file_name)
          setup_asset asset_file

          Cms::Asset.any_instance.stubs(:asset => stub(:path => asset_file))
          Cms::Asset.any_instance.expects(:file_content=).with('new content').returns('new content')
        end

        teardown do
          assert_equal 'The asset has been updated.', flash[:notice]
          @asset.reload
          assert_not_nil @asset.meta_data
          assert_equal 2, @asset.meta.length
        end

        should "modify the contents of an editable asset file and it's meta data" do
          assert_nil @asset.meta_data
          assert_equal 0, @asset.meta.length

          put :update, :id => @asset, :cms_asset => {:file_content => 'new content', :meta => {'new_0' => {:name => 'key_a', :value => 'test'}, 'new_1' => {:name => 'key_b', :value => 'test'}}}
          assert_response :redirect
          assert_redirected_to edit_cms_asset_path(@asset)
        end

        should "update via XHR" do
          xhr :put, :update, :id => @asset, :cms_asset => {:file_content => 'new content', :meta => {'new_0' => {:name => 'key_a', :value => 'test'}, 'new_1' => {:name => 'key_b', :value => 'test'}}}
          assert_response :success
        end
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
    end
  end
end
