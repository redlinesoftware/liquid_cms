class Cms::PagesController < Cms::MainController
  skip_before_filter :verify_authenticity_token, :only => [:load, :page_asset]

  authenticate_user :all, :except => %w(load page_asset)

  SEARCH_LIMIT = 40

  def new
    @page = Cms::Page.new
  end

  def create
    @page = @context.pages.build(params[:cms_page])
    if @page.save
      flash[:notice] = t('pages.flash.created')
      redirect_to cms_root_path
    else
      render :action => 'new'
    end
  end

  def edit
    @page = @context.pages.find params[:id]
  end

  def update
    @page = @context.pages.find params[:id]
    if @page.update_attributes(params[:cms_page])
      flash[:notice] = t('pages.flash.updated')
      redirect_to edit_cms_page_path(@page)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @page = @context.pages.find(params[:id])
    @page.destroy

    flash[:notice] = t('pages.flash.deleted')
    
    respond_to do |format|
      format.html { redirect_to cms_root_path }
      format.js
    end
  end

  def load
    # forces removal of any flash values used during this request
    flash.discard

    path = '/'+params[:url].join('/')

    @page = if path == '/'
      # if the root path is requested, find the root page or if a root page doesn't exist, get the first published page
      @context.pages.root || @context.pages.published.first
    else
      @context.pages.published.first(:conditions => {:slug => path}) || @context.pages.published.first(:conditions => {:name => params[:url].first}) || @context.pages.published.first(:conditions => {:slug => wildcard_path}) 
    end

    if @page
      response.content_type = @page.content_type
      begin
        render :text => @page.rendered_content(self)
      rescue Liquid::SyntaxError, Liquid::ArgumentError, ArgumentError
        render :text => $!.message
      rescue Exception => e
        # add the page content to the exception for a debugging aid
        f = e.class.new(e.message + "\n\n" + @page.content)
        f.set_backtrace e.backtrace
        raise f
      end
    else
      raise ActionController::RoutingError, "No route matches #{params.inspect}"
    end
  end

  # for loading stylesheets or javascript content
  def page_asset
    @page = @context.pages.find_by_name [params[:id], params[:format]].compact.join('.')

    if @page
      response.content_type = @page.content_type
      render :text => @page.rendered_content(self)
    else
      render :nothing => true, :status => 404
    end
  end

  def search
    @search_term = (params[:search] || '').strip
    # use upper which should be compatible with mysql, postgresql and sqlite
    @pages = @search_term.blank? ? [] : @context.pages.all(:conditions => ["upper(content) like ?", "%#{@search_term.upcase}%"])
  end

protected
  # the current url with the last level of the path removed which essentially allows a page to be loaded with anything (wildcard) one level deeper
  # ex. normal page at /page will also accept /page/test, /page/abcd, etc.
  def wildcard_path
    '/'+params[:url].slice(0..-2).join('/')
  end
end
