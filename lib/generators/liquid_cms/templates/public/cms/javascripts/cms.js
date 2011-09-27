// set or delete a cookie value to remember the folders view state
function set_component_view_state(elem) {
  var key = elem.getAttribute('id');
  var current_folders = jar.get('component_folders') || {};

  if (elem.next('ul').visible())
    current_folders[key] = true;
  else
    delete current_folders[key];

  jar.put('component_folders', current_folders);
}

function toggle_component() {
  $(this).next('ul').toggle();
  set_component_view_state(this);
}

function asset_preview_toggle() {
  var previews = $$('.asset_details');

  if (previews.length > 0) {
    previews.invoke('toggle');
    jar.put('toggle', {on:previews.first().visible()});
  }
}

function codemirrorToggleFullscreenEditing()
{
  var editorDiv = $$('.CodeMirror-scroll').first();

  if (!editorDiv.hasClassName('fullscreen')) {
    var height = document.viewport.getHeight()+document.viewport.getScrollOffsets()[1];

    toggleFullscreenEditing.beforeFullscreen = { height: editorDiv.getHeight(), width: editorDiv.getWidth() }
    editorDiv.addClassName('fullscreen');
    editorDiv.setStyle({height:height+'px', width:'100%'});
    editor.refresh();
  }
  else {
    editorDiv.removeClassName('fullscreen');
    editorDiv.setStyle({
      height:toggleFullscreenEditing.beforeFullscreen.height,
      width:toggleFullscreenEditing.beforeFullscreen.width
    });
    editor.refresh();
  }
}

function codemirrorSave(editor, form, use_ajax) {
  editor.save();

  if (!use_ajax) {
    form.submit();
    return;
  }

  var has_indicator = $('indicator');

  if (has_indicator)
    Element.show('indicator');

  new Ajax.Request(form.action, {asynchronous:true, evalScripts:true, onComplete:
    function(request){
      if (has_indicator)
        Element.hide('indicator');

      form.enable();
    },
    parameters:form.serialize()}
  );

  form.disable();
}

function initCodemirror(mode, form, textarea, use_ajax) {
  var codeMirrorOptions = {
    mode : mode,
    onKeyEvent : function(instance, event){
      if (event.type == 'keydown') {
        if (event.ctrlKey && (event.which == 83 || event.keyCode == 83)) {
          event.stop();
          codemirrorSave(instance, form, use_ajax);
        }
        // Hook into F11
        //else if (event.keyCode == 122 || event.keyCode == 27) {
        //  event.stop();
        //  codemirrorToggleFullscreenEditing();
        //}
      }
    }
  }

  var editor = CodeMirror.fromTextArea(textarea, codeMirrorOptions);
}

$(document).observe('dom:loaded', function() {
  $$('#components .folder').each(function(elem) {
    elem.observe('click', toggle_component);
  });
});

var cookie_expiry = 60 * 60 * 24 * 30 * 3; // 3 months
var jar = new CookieJar({expires:cookie_expiry, path:'/cms'});
