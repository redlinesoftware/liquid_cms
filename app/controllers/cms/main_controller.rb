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

    @pages = @context.pages.ordered.all(:conditions => {:layout_page_id => nil})
    @assets = @context.assets.ordered
    @components = @context.components
  end
end
