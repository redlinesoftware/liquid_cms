module AssetHelpers
  def setup_asset(file_name)
    FileUtils.mkdir_p File.dirname(file_name)
    FileUtils.touch file_name
  end

  def cleanup_assets
    FileUtils.rm_rf TestConfig.paperclip_test_root
    FileUtils.rm_rf Rails.root.join('public', 'cms', 'assets')
  end

  def asset_path
    TestConfig.paperclip_test_root + '/assets'
  end

  def asset_file(file_name)
    File.expand_path asset_path + "/" + file_name
  end
end
