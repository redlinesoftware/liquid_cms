module Cms::ComponentsHelper
  def component_folder_open?(folder_id)
    cookie_jar('component_folders')[folder_id].present?
  end

  def component_edit_link(path)
    full_path = Cms::Component.component_path(@context, path)
    link_to(truncate(File.basename(path), :length => 15), {:controller => 'cms/components', :action => 'edit', :url => CGI::escape(full_path)})
  end

  def component_delete_link(path)
    full_path = Cms::Component.component_path(@context, path)
    link_to(cms_icon('delete.png', :title => 'Delete'), {:controller => 'cms/components', :action => 'destroy', :url => CGI::escape(full_path)}, :confirm => "Are you sure you want to remove '#{full_path}'?")
  end

  def list_files(files, hidden = false)
    html = ''
    html += hidden ? %[<ul class="tree" style="display:none">] : %[<ul class="tree">]
    for file in files do
      html += "<li>"
      if File.directory?(file)
        folder_id = "folder_#{Digest::MD5.hexdigest(file)}"

        html += cms_icon('folder.png', :class => 'folder', :id => folder_id) + ' ' + component_delete_link(file) + ' '
        html += content_tag(:span, File.basename(file), :title => Cms::Component.component_path(@context, file))
        html += list_files(Cms::Component.files(file), !component_folder_open?(folder_id))
      else
        html += file_type_icon(File.basename(file)) + ' '
        html += component_delete_link(file) + ' '
        if Cms::Component.editable?(file)
          html += component_edit_link(file)
        else
          html += content_tag(:span, truncate(File.basename(file), :length => 15), :title => Cms::Component.component_path(@context, file))
        end
      end
      html += "</li>"
    end
    html += "</ul>"
    html
  end
end
