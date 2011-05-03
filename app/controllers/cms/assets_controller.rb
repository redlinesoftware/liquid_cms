class Cms::AssetsController < Cms::MainController
  authenticate_user :all

  def show
    @asset = @context.assets.find params[:id]
  end

  def new
    @asset = create_tagged_asset
  end

  def create
    asset_attrs = params[:cms_asset].delete(:asset)

    # force the asset to be assigned last so that the custom dims can be set if they're present
    # if the custom dims aren't set before the asset is assigned, the custom size won't be generated properly
    @asset = @context.assets.build params[:cms_asset]
    @asset.asset = asset_attrs if asset_attrs.present?

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
    asset_attrs = params[:cms_asset].delete(:asset)

    @asset = @context.assets.find params[:id]

    # force the asset to be assigned last so that the custom dims can be set if they're present
    # if the custom dims aren't set before the asset is assigned, the custom size won't be generated properly
    @asset.attributes = params[:cms_asset]
    @asset.asset = asset_attrs if asset_attrs.present?

    if @asset.save
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
