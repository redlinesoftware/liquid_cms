class Cms::MainController < Cms::SetupController
  unloadable
  extend Cms::RoleAuthentication

  layout 'cms'

  before_filter :load_resources

  authenticate_user :all, :only => %w(index)

  def index
    render :partial => 'cms/shared/index', :layout => true
  end

protected
  def load_resources
    @context = Cms::Context.new(@cms_context)

    @cms_pages = @context.pages.ordered.all(:conditions => {:layout_page_id => nil})
    @cms_assets = @context.assets.ordered
    @cms_components = @context.components
  end
end
