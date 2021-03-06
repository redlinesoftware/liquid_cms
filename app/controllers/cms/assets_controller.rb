class Cms::AssetsController < Cms::MainController
  authenticate_user :all

  def show
    @asset = @context.assets.find params[:id]
  end

  def new
    @asset = create_tagged_asset
  end

  def create
    @asset = @context.assets.build
    @asset.assign_ordered_attributes params[:cms_asset]

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
    @asset.assign_ordered_attributes params[:cms_asset]

    if @asset.save
      respond_to do |format|
        format.html {
          redirect_to edit_cms_asset_path(@asset), :notice => t('assets.flash.updated')
        }
        format.js {
          flash.now[:notice] = t('assets.flash.updated')
        }
      end
    else
      respond_to do |format|
        format.html {
          render :action => 'edit'
        }
        format.js
      end
    end
  end

  def destroy
    @asset = @context.assets.find(params[:id])
    @asset.destroy

    flash[:notice] = t('assets.flash.deleted')

    respond_to do |format|
      format.html { redirect_to cms_root_path }
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
      end

      dims_asset = @context.assets.tagged_with(curr_tag).first :conditions => 'custom_width is not null and custom_height is not null'
      if dims_asset
        # assign custom dims
        asset.custom_width = dims_asset.custom_width
        asset.custom_height = dims_asset.custom_height
      end

      asset
    else
      asset
    end
  end
end
