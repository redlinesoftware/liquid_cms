require File.expand_path('../../test_helper', __FILE__)

class Cms::AssetTest < ActiveSupport::TestCase
  def setup
    @context = Factory(:company)
  end

  def teardown
    cleanup_assets
  end

  context "asset field" do
    setup do
      @asset = Factory(:image_asset, :context => @context)
      @fname = File.expand_path('../../rails_app/public/images/rails.png', __FILE__)
    end

    should "have a valid custom file" do
      %w(original tiny thumb custom).each do |type|
        assert_nil @asset.asset.to_file(type)
      end

      @asset.asset = nil
      @asset.asset = File.open(@fname)
      @asset.save

      %w(original tiny thumb custom).each do |type|
        assert_not_nil @asset.asset.to_file(type)
      end
    end

    should "create an image with a custom size" do
      # check normal size first
      @asset.asset = File.open(@fname)
      @asset.save

      assert_equal '50x64', Paperclip::Geometry.from_file(@asset.asset.path(:custom)).to_s

      # assign custom dimensions
      @asset.custom_width = 5
      @asset.custom_height = 5
      @asset.save

      # check new dimensions
      assert_equal '4x5', Paperclip::Geometry.from_file(@asset.asset.path(:custom)).to_s
    end

    should "correctly create a custom asset while assigning the asset and dims at the same time" do
      asset_attrs = {:asset => File.open(@fname), :custom_height => '10', :custom_width => '5'}
      @asset.assign_ordered_attributes asset_attrs
      @asset.save
      assert_equal '50x64', Paperclip::Geometry.from_file(@asset.asset.path(:original)).to_s
      assert_equal '5x6', Paperclip::Geometry.from_file(@asset.asset.path(:custom)).to_s
    end
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
        assert_equal '', @asset.file_content
        assert_equal false, @asset.send(:write, 'test')
        assert_equal 'test', @asset.file_content=('test')
        assert_equal '', @asset.file_content
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
        assert_equal '', @asset.file_content
        assert_equal false, @asset.send(:write, 'test')
        assert_equal 'test', @asset.file_content=('test')
        assert_equal '', @asset.file_content
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
        assert_equal '', @asset.file_content
        assert_equal false, @asset.send(:write, 'test')
        assert_equal 'test', @asset.file_content=('test')
        assert_equal '', @asset.file_content
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
        assert_equal true, @asset.send(:write, "alert('test')")
        assert_equal "alert('test')", @asset.file_content=("alert('test')")
        assert_equal "alert('test')\n", @asset.file_content
      end
    end
  end

  context "tags" do
    setup do
      @asset = Factory(:image_asset, :context => @context)
    end
    
    should "be untagged" do
      assert_nil @context.assets.tagged.find_by_id(@asset.id)
      assert_not_nil @context.assets.untagged.find_by_id(@asset.id)
    end

    should "be tagged" do
      @asset.tag_list = "test, this stuff"
      @asset.save

      assert_not_nil @context.assets.tagged.find_by_id(@asset.id)
      assert_not_nil @context.assets.tagged_with('test').find_by_id(@asset.id)
      assert_not_nil @context.assets.tagged_with('this').find_by_id(@asset.id)
      assert_not_nil @context.assets.tagged_with('stuff').find_by_id(@asset.id)
      assert_nil @context.assets.tagged_with('notthis').find_by_id(@asset.id)
      assert_nil @context.assets.untagged.find_by_id(@asset.id)
    end
  end

  context "meta data" do
    setup do
      @asset = Factory(:image_asset, :context => @context)
    end

    should "assign meta data" do
      @asset.meta = {'new_1' => {:name => 'test name 1', :value => 'test value 1'}, 'new_2' => {:name => ' ', :value => 'test value 2'}}
      assert @asset.meta_data.is_a?(Array)
      assert_equal 2, @asset.meta_data.length
    end

    should "validate" do
      @asset.meta = {'new_1' => {:name => 'test name 1', :value => 'test value 1'}, 'new_2' => {:name => ' ', :value => 'test value 2'}}
      assert !@asset.valid?
      assert_equal "is invalid", @asset.errors[:meta_data].first
      assert_equal "is an invalid format", @asset.meta[0].errors[:name].first
      assert_equal "must be set", @asset.meta[1].errors[:name].first

      @asset.meta = {'new_1' => {:name => 'test_name', :value => 'test value 1'}, 'new_2' => {:name => 'new_$', :value => 'test value 2'}}
      assert !@asset.valid?
      assert_equal "is invalid", @asset.errors[:meta_data].first
      assert @asset.meta[0].errors.empty?
      assert_equal "is an invalid format", @asset.meta[1].errors[:name].first
      
      @asset.meta = {'new_1' => {:name => 'test_name', :value => 'test value 1'}, 'new_2' => {:name => 'new_2', :value => 'test value 2'}}
      assert @asset.valid?
      assert @asset.meta[0].errors.empty?
      assert @asset.meta[1].errors.empty?
    end
  end
end
