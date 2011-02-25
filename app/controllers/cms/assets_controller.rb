class Cms::AssetsController < Cms::MainController
  authenticate_user :all

  def show
    @asset = @context.assets.find params[:id]
  end

  def new
    @asset = Cms::Asset.new
  end

  def create
    @asset = @context.assets.build params[:cms_asset]
    if @asset.save
      flash[:notice] = t('assets.flash.created')
      redirect_to cms_root_path
    else
      render :action => 'new'
    end
  end

  def edit
    @asset = @context.assets.find params[:id]
  end

  def update
    @asset = @context.assets.find params[:id]

    success = if params[:file_content].present?
      @asset.write params[:file_content]
    else
      @asset.update_attributes params[:cms_asset]
    end

    if success
      flash[:notice] = t('assets.flash.updated')
      redirect_to cms_root_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @asset = @context.assets.find(params[:id])
    @asset.destroy

    flash[:notice] = t('assets.flash.deleted')
    
    respond_to do |format|
      format.html { redirect_to cms_root_path }
      format.js
    end
  end
end
