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

CodeMirror.defineMode("liquid", function(config, parserConfig) {
  var liquidOverlay = {
    token: function(stream, state) {
      if (stream.match("{{", false)) {
        stream.match("{{");
        while ((ch = stream.next()) != null)
          if (ch == "}" && stream.next() == "}") break;
        return "liquid-control";
      }

      if (stream.match("{%", false)) {
        stream.match("{%");
        while ((ch = stream.next()) != null)
          if (ch == "%" && stream.next() == "}") break;
        return "liquid-output";
      }

      while (stream.next() != null && !stream.match("{{", false) && !stream.match("{%", false)) {}
      return null;
    }
  };

  return CodeMirror.overlayParser(CodeMirror.getMode(config, parserConfig.backdrop || "text/html"), liquidOverlay);
});

function initCodemirror(mode, form, textarea, use_ajax, liquid_support) {
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

  if (liquid_support)
    codeMirrorOptions.mode = 'liquid';

  var editor = CodeMirror.fromTextArea(textarea, codeMirrorOptions);
}
