require File.expand_path('../../test_helper', __FILE__)

class Cms::ComponentTest < ActiveSupport::TestCase
  def setup
    @context = Cms::Context.new(nil)
  end
  
  context "no context" do
    should "have valid paths" do
      assert_equal 'cms/components', Cms::Component.base_path(@context).to_s
      assert_equal Rails.root.to_s + '/public/cms/components', Cms::Component.full_path(@context).to_s
      assert_equal 'zipdir/test.jpg', Cms::Component.component_path(@context, Cms::Component.full_path(@context).join('zipdir', 'test.jpg')).to_s
      assert_equal '', Cms::Component.component_path(@context, Cms::Component.full_path(@context).join('..', 'zipdir', 'test.jpg')).to_s
    end

    should "verify valid extensions" do
      assert Cms::Component.valid_ext?('test.jpg')
      assert Cms::Component.valid_ext?('test.JPG')
      assert !Cms::Component.valid_ext?('test.bmp')

      Cms.valid_component_exts += %w(.bmp)

      assert Cms::Component.valid_ext?('test.jpg')
      assert Cms::Component.valid_ext?('test.JPG')
      assert Cms::Component.valid_ext?('test.bmp')
    end

    should "check for being editable" do
      assert !Cms::Component.editable?('test.jpg')
      assert !Cms::Component.editable?('test.JPG')
      assert Cms::Component.editable?('test.txt')
      assert Cms::Component.editable?('test.TXT')
      assert !Cms::Component.editable?('test.xhtml')

      Cms.editable_component_exts += %w(.xhtml)

      assert Cms::Component.editable?('test.xhtml')
    end

    context "component instance" do
      setup do
        file = File.join('path', 'to', 'file.js')
        setup_component Cms::Component.full_path(@context).join(file)
        @component = Cms::Component.new(@context, file)
      end

      teardown do
        cleanup_components
      end

      should "be able to perform file operations" do
        assert_equal true, @component.write("alert('test')")
        assert_equal "alert('test')\n", @component.read
        assert_equal true, @component.delete
      end

      should "expand a zip file" do
        create_zip 'test.zip' do |path|
          Cms::Component.expand @context, path

          assert File.exist?(Cms::Component.full_path(@context).join('test.txt'))
          assert !File.exist?(Cms::Component.full_path(@context).join('test.ext'))
          assert File.exist?(Cms::Component.full_path(@context).join('dir', 'test.txt'))
          assert !File.exist?(Cms::Component.full_path(@context).join('dir', 'test.exe'))
          assert !File.exist?(Cms::Component.full_path(@context).join('../../dir', 'test.exe'))
          assert !File.exist?(Cms::Component.full_path(@context).join('../../dir', 'test.txt'))
        end
      end
    end
  end

protected
  def create_zip(name)
    fname = Rails.root.join('public', 'cms', 'temp').join(name)
    FileUtils.mkdir_p File.dirname(fname)

    begin
      Zip::ZipFile.open(fname, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.get_output_stream("test.txt") {}
        zipfile.get_output_stream("test.exe") {} # invalid file ext will be ignored
        zipfile.mkdir("dir")
        zipfile.get_output_stream("dir/test.exe") {}
        zipfile.get_output_stream("dir/test.txt") {}
        zipfile.get_output_stream("../../dir/test.exe") {} # relative path file will be ignored
        zipfile.get_output_stream("../../dir/test.txt") {} # relative path file will be ignored 
      end

      yield fname

    ensure
      cleanup_files 'temp'
    end
  end
end
