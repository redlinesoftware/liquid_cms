class Cms::ComponentsController < Cms::MainController
  authenticate_user :all

  before_filter :load_component_path, :except => :upload

  def edit
    if Cms::Component.editable?(@path)
      @component = Cms::Component.new(@context, @path)
    else
      flash[:error] = "Not an editable component."
      redirect_to cms_root_path
    end
  end

  def update
    edit_url = {:controller => 'cms/components', :action => 'edit', :url => @path}

    if Cms::Component.editable?(@path)
      @component = Cms::Component.new(@context, @path)
      @component.write params[:file_content]

      respond_to do |format|
        format.html {
          redirect_to edit_url, :notice => t('components.flash.updated')
        }
        format.js {
          flash.now[:notice] = t('components.flash.updated')
        }
      end
    else
      flash[:error] = "Not an editable component."
      redirect_to edit_url
    end
  end

  def destroy
    if @path.present? && Cms::Component.new(@context, @path).delete
      flash[:notice] = 'The component has been removed.'
    else
      flash[:error] = 'The component path was invalid.'
    end

    redirect_to cms_root_path
  end

  def upload
    component_zip = params[:zip_file]

    if component_zip.present? && File.extname(component_zip.original_filename) == '.zip'
      Cms::Component.expand @context, component_zip.path
      flash[:notice] = 'The component has been uploaded.'
    else
      flash[:error] = 'The component file must be a zip archive.'
    end

    redirect_to cms_root_path
  end

protected
  def load_component_path
    @path = params[:url]
    @path = CGI::unescape(@path) if @path.present?
  end
end
