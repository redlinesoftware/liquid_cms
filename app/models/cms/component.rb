require 'zip/zip'

class Cms::Component
  attr_reader :path
  
  def initialize(context, path = nil)
    @context = context
    @path = self.class.clean_path(path) if path
  end

  # base public path for components
  def self.base_path(context)
    Pathname.new(File.join('cms', context.object ? File.join('components', context.object.id.to_s) : 'components'))
  end

  # full component path on the local system
  def self.full_path(context)
    Rails.root.join 'public', base_path(context)
  end

  # the path for just the current component file as it existed in the original zip file
  # returns empty if the path isn't in the main component directory which occurs if the zip contained relative references
  # path: the full path of the component on the file system
  def self.component_path(context, path)
    path.to_s.include?(full_path(context).to_s) ? path.sub(full_path(context).to_s + "/", '') : ''
  end

  def self.files(path)
    Dir[File.expand_path(path) + "/*"]
  end

  def self.valid_ext?(file)
    Cms.valid_component_exts.include?(File.extname(file).downcase)
  end

  def self.expand(context, file)
    Zip::ZipFile.open(file) do |zip_file|
      zip_file.each do |f|
        f_path = full_path(context).join(f.name)
        if valid_ext?(f_path) && component_path(context, f_path).present?
          FileUtils.mkdir_p f_path.dirname
          FileUtils.rm_rf(f_path.to_s) if f_path.exist?
          zip_file.extract(f, f_path.to_s)
        end
      end
    end
  end

  def read
    return '' if @path.blank? || !self.class.editable?(@path)

    fname = self.class.full_path(@context).join(@path)
    if File.exist?(fname)
      File.open(fname).read
    else
      ''
    end
  end

  def write(content)
    return false if content.blank? || @path.blank? || !self.class.editable?(@path)

    fname = self.class.full_path(@context).join(@path)
    File.exist?(fname).tap do |exist|
      File.open(fname, 'w') do |f|
        f.puts content
      end if exist
    end
  end
  
  def delete
    return false if @path.blank?

    fname = self.class.full_path(@context).join(@path)
    File.exist?(fname).tap do |exist|
      FileUtils.rm_rf fname if exist
    end
  end

  def self.editable?(file)
    Cms.editable_component_exts.include?(File.extname(file).downcase)
  end

protected
  # cleans the path to remove relative references, etc. to other areas of the filesystem
  def self.clean_path(path)
    # don't do anything if the root path is present
    return nil if path.blank? || path[0] == "/"

    # remove any occurences of .. and * with nothing in the path
    path.gsub(/\.\./, '').gsub(/\*/,'')
  end
end
