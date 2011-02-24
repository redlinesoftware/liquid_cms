require File.expand_path('../../test_helper', __FILE__)

class Cms::AssetTest < ActiveSupport::TestCase
  def setup
    @context = Factory(:company)
  end

  def teardown
    cleanup_assets
  end

  context "type checks" do
    setup do
      @asset = Factory(:image_asset, :context => @context)
    end

    context "new image" do
      setup do
        @asset = Cms::Asset.new
      end

      should "not be an image" do
        assert !@asset.image?
      end
      should "not be an icon" do
        assert !@asset.icon?
      end
      should "not be editable" do
        assert !@asset.editable?
      end
      should "not be able to read or write" do
        assert_equal '', @asset.read
        assert_equal false, @asset.write('test')
      end
    end

    context "image" do
      should "be an image" do
        assert @asset.image?
      end
      should "not be an icon" do
        assert !@asset.icon?
      end
      should "not be editable" do
        assert !@asset.editable?
      end
      should "not be able to read or write" do
        assert_equal '', @asset.read
        assert_equal false, @asset.write('test')
      end
    end

    context "icon" do
      setup do
        @asset.update_attribute :asset_content_type, 'image/ico'
      end
      should "be an image" do
        assert @asset.image?
      end
      should "be an icon" do
        assert @asset.icon?
      end
      should "not be editable" do
        assert !@asset.editable?
      end
      should "not be able to read or write" do
        assert_equal '', @asset.read
        assert_equal false, @asset.write('test')
      end
    end

    context "javascript" do
      setup do
        @asset.update_attribute :asset_content_type, 'text/javascript'
        setup_asset @asset.asset.path(:original)
      end

      should "not be an image" do
        assert !@asset.image?
      end
      should "not be an icon" do
        assert !@asset.icon?
      end
      should "be editable" do
        assert @asset.editable?
      end
      should "be able to read or write" do
        assert_equal true, @asset.write("alert('test')")
        assert_equal "alert('test')\n", @asset.read
      end
    end
  end
end
