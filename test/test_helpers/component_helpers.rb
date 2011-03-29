require File.expand_path('../file_helpers', __FILE__)

module ComponentHelpers
  include FileHelpers

  def setup_component(file_name)
    setup_file file_name
  end

  def cleanup_components
    cleanup_files 'components'
  end

  def create_zip(name)
    path = Pathname.new(File.join('public', 'cms', 'temp', name))
    fname = Rails.root.join('test', 'fixtures', path).to_s

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

      yield fname, path

    ensure
      cleanup_files 'temp'
    end
  end
end
