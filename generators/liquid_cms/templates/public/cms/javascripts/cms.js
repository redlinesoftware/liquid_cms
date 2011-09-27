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

$(document).observe('dom:loaded', function() {
  $$('#components .folder').each(function(elem) {
    elem.observe('click', toggle_component);
  });
});

var cookie_expiry = 60 * 60 * 24 * 30 * 3; // 3 months
var jar = new CookieJar({expires:cookie_expiry, path:'/cms'});
