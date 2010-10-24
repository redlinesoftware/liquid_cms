function toggle_component() {
  $(this).next('ul').toggle();
}

function asset_preview_toggle() {
  var previews = $$('.asset_details');

  if (previews.length > 0) {
    previews.invoke('toggle');
    jar.put('toggle', {on:previews.first().visible()});
  }
}

$(document).observe('dom:loaded', function() {
  $$('#components .folder').each(function(elem) {
    elem.observe('click', toggle_component);
  });
});

var cookie_expiry = 60 * 60 * 24 * 30; // 1 month
var jar = new CookieJar({expires:cookie_expiry, path:'/cms'});
