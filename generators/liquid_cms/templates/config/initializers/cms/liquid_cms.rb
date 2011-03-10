Cms.setup do |config|
  # Valid component file extensions that are allowed to be uploaded to the CMS.
  # Defaults to %w(.css .js .png .jpg .jpeg .gif .json .xml .fla .ico .txt)
  #config.valid_component_exts += %w(.xhtml .bmp)

  # Compnent file types that can be edited (text based) in the CMS. Make sure new extensions here are also set in the valid_component_exts setting.
  # Defaults to %w(.js .css .html .xml .txt)
  #config.editable_component_exts += %w(.xhtml)

  # The class of your apps context object if it has one. This attribute must be set last.
  #config.context_class = :Context
end
