require File.expand_path('../file_helpers', __FILE__)

module ComponentHelpers
  include FileHelpers

  def setup_component(file_name)
    setup_file file_name
  end

  def cleanup_components
    cleanup_files 'components'
  end
end
