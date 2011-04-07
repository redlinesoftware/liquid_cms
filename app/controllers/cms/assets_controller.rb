class Cms::AssetsController < Cms::MainController
  authenticate_user :all

  def show
    @asset = @context.assets.find params[:id]
  end

  def new
    @asset = create_tagged_asset
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

    if @asset.update_attributes params[:cms_asset]
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

protected
  # pre-populate an asset with tagged data and meta fields if a tag param is present
  def create_tagged_asset
    asset = Cms::Asset.new
    curr_tag = (params[:tag] || '').strip

    if curr_tag.present?
      asset.tag_list = curr_tag
    
      meta_asset = @context.assets.tagged_with(curr_tag).first :conditions => 'meta_data is not null'
      if meta_asset
        # remove meta values since we only want the key names
        # new values will be provided for the new asset
        asset.meta_data = meta_asset.meta_data.collect{|m| {:name => m[:name], :value => ''}}

        # assign custom dims
        asset.custom_width = meta_asset.custom_width
        asset.custom_height = meta_asset.custom_height
      end

      asset
    else
      asset
    end
  end
end
