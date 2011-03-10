module FileHelpers
  def setup_file(file_name)
    FileUtils.mkdir_p File.dirname(file_name)
    FileUtils.touch file_name
  end

  def cleanup_files(dir)
    FileUtils.rm_rf TestConfig.paperclip_test_root
    FileUtils.rm_rf Rails.root.join('public', 'cms', dir)
  end
end
