var RemoteHelpers = {
  init : function() {
    $$('a[data-remote=true]').each(function(elem) {
      RemoteHelpers.registerHandlers(elem);
    });
  },

  registerHandlers : function(elem) {
    elem.observe('ajax:before', function(event) {
      var indicator = elem.readAttribute('indicator');
      if (indicator) {
        $(indicator).show();
      }
    });
    elem.observe('ajax:complete', function(event) {
      var indicator = elem.readAttribute('indicator');
      if (indicator) {
        $(indicator).hide();
      }
    });
  }

/*
  $$('form[data-remote=true]').each(function(elem) {
    if (elem.readAttribute('disable-form') == true) {
      elem.observe('ajax:before', function(event) {
        elem.store('disabled_elems', []);
      });
      elem.observe('ajax:after', function(event) {
        elem.store('disabled_elems', this.select(':disabled'));
        Form.disable(this);
      });
      elem.observe('ajax:complete', function(event) {
        Form.enable(this);
        elem.retrieve('disabled_elems').invoke('disable');
      });

      remote_handlers(elem);
    }
  });
*/
};

$(document).observe('dom:loaded', function() { RemoteHelpers.init() });
