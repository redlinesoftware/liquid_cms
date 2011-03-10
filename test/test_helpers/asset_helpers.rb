require File.expand_path('../file_helpers', __FILE__)

module AssetHelpers
  include FileHelpers

  def setup_asset(file_name)
    setup_file file_name
  end

  def cleanup_assets
    cleanup_files 'assets'
  end

  def asset_path
    TestConfig.paperclip_test_root + '/assets'
  end

  def asset_file(file_name)
    asset_path + "/" + file_name
  end
end
