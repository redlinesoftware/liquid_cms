require File.dirname(__FILE__) + '/../test_helper'

class Cms::ComponentsControllerTest < ActionController::TestCase
  def setup
    setup_company_and_login_admin
    @context = Cms::Context.new(@company)
  end

  context "component file" do
    teardown do
      cleanup_components
    end

    context "editable" do
      setup do
        @file = File.join('path', 'to', 'file.js')
        setup_component Cms::Component.full_path(@context).join(@file)
      end

      teardown do
        cleanup_components
      end

      should "edit" do
        get :edit, :url => [@file]
        assert_response :success
        assert_template 'edit'
      end

      context "update" do
        should "update via HTTP" do
          put :update, :url => [@file], :file_content => 'new content'
          assert_response :redirect
          assert_redirected_to :controller => 'cms/components', :action => 'edit', :url => @file
          assert_equal "The component file has been updated.", flash[:notice]
          assert_equal "new content\n", File.read(Cms::Component.full_path(@context).join(@file))
        end

        should "update via XHR" do
          xhr :put, :update, :url => [@file], :file_content => 'new content'
          assert_response :success
          assert_equal "The component file has been updated.", flash[:notice]
          assert_equal "new content\n", File.read(Cms::Component.full_path(@context).join(@file))
        end
      end

      should "valid destroy" do
        delete :destroy, :url => [@file]
        assert_response :redirect
        assert_equal "The component has been removed.", flash[:notice]
      end

      should "invalid destroy" do
        delete :destroy, :url => [@file+'.bak']
        assert_response :redirect
        assert_equal "The component path was invalid.", flash[:error]
      end
    end

    context "non-editable" do
      setup do
        @file = File.join('path', 'to', 'file.jpg')
        setup_component Cms::Component.full_path(@context).join(@file)
      end

      should "edit" do
        get :edit, :url => [@file]
        assert_response :redirect
        assert_equal "Not an editable component.", flash[:error]
      end

      should "update" do
        put :update, :url => [@file], :file_content => 'new content'
        assert_response :redirect
        assert_equal "Not an editable component.", flash[:error]
      end
    end
  end

  context "upload" do
    teardown do
      cleanup_components
    end

    should "successfully upload a valid zip" do
      create_zip 'test.zip' do |path|
        post :upload, :zip_file => ActionController::TestUploadedFile.new(path)
        assert_response :redirect
        assert_equal 'The component has been uploaded.', flash[:notice]

        assert File.exist?(Cms::Component.full_path(@context).join('test.txt'))
        assert !File.exist?(Cms::Component.full_path(@context).join('test.ext'))
        assert File.exist?(Cms::Component.full_path(@context).join('dir', 'test.txt'))
        assert !File.exist?(Cms::Component.full_path(@context).join('dir', 'test.exe'))
        assert !File.exist?(Cms::Component.full_path(@context).join('../../dir', 'test.exe'))
        assert !File.exist?(Cms::Component.full_path(@context).join('../../dir', 'test.txt'))
      end
    end

    should "produce an error" do
      create_zip 'test.bmp' do |path|
        post :upload, :zip_file => ActionController::TestUploadedFile.new(path)
        assert_response :redirect
        assert_equal 'The component file must be a zip archive.', flash[:error]
      end
    end
  end
end
