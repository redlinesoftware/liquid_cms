require 'zip/zip'

class Cms::Component

  attr_reader :path
  
  def initialize(context, path = nil)
    @context = context
    @path = clean_path(path) if path
  end

  def self.base_path(context)
    File.join('cms', context.object ? File.join('components', context.object.id.to_s) : 'components')
  end

  def self.full_path(context)
    Rails.root.join 'public', base_path(context)
  end

  def self.component_path(context, path)
    path.sub(full_path(context).to_s + "/", '')
  end

  def self.valid_type?(file)
    %w(.css .js .png .jpg .jpeg .gif .json .xml .fla .ico).include?(File.extname(file).downcase)
  end

  def expand(file)
    Zip::ZipFile.open(file) do |zip_file|
      zip_file.each do |f|
        f_path = self.class.full_path(@context).join(f.name)
        #if !File.exist?(f_path) && self.class.valid_type?(f_path)
        if self.class.valid_type?(f_path)
          FileUtils.mkdir_p File.dirname(f_path)
          FileUtils.rm_rf(f_path) if File.exist?(f_path)
          zip_file.extract(f, f_path)
        end
      end
    end
  end

  def read
    return '' if @path.blank? || !self.class.editable?(@path)

    base = self.class.full_path(@context).join(@path).to_s
    if File.exist?(base)
      File.open(base).readlines
    else
      ''
    end
  end

  def write(content)
    return false if content.blank? || @path.blank? || !self.class.editable?(@path)

    base = self.class.full_path(@context).join(@path).to_s
    if File.exist?(base)
      File.open(base, 'w') do |f|
        f.puts content
      end
    else
      ''
    end
  end
  
  def delete
    return false if @path.blank?

    base = self.class.full_path(@context).join(@path)
    if File.exist?(base)
      FileUtils.rm_rf base
      true
    else
      false
    end
  end

  def self.editable?(file)
    !(file =~ /\.(js|css|html|xml)$/).nil?
  end

protected
  def clean_path(path)
    # don't do anything if the root path is present
    return nil if path.blank? || path[0] == "/"

    # remove any occurences of .. and * with nothing in the path
    path.gsub(/\.\./, '').gsub(/\*/,'')
  end
end
