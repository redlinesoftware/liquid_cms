/*
  HUMANIZED MESSAGES 1.0
  idea - http://www.humanized.com/weblog/2006/09/11/monolog_boxes_and_transparent_messages
  home - http://humanmsg.googlecode.com
*/

var humanMsg = {
  setup: function(appendTo, logName, msgOpacity) {
    humanMsg.msgID = 'humanMsg';
    humanMsg.logID = 'humanMsgLog';

    appendTo = appendTo || $$('body')[0];
    logName = logName || 'Message Log';

    humanMsg.msgOpacity = 0.8;
    if (msgOpacity !== undefined) {
      humanMsg.msgOpacity = parseFloat(msgOpacity);
    }

    var myTemplate = new Template(
      '<div id="#{msgID}" class="humanMsg" style="display:none;">'+
        '<div class="round"></div>'+
        '<p></p>'+
        '<div class="round"></div>'+
       '</div> '+

      '<div id="#{logID}">'+
        '<p style="display:none;">#{logName}</p>'+
        '<ul style="display:none;"></ul>'+
      '</div>');
    var show = {msgID: humanMsg.msgID, logID: humanMsg.logID, logName: logName};
    appendTo.insert(myTemplate.evaluate(show));

    $(humanMsg.logID).down('p').observe('click', function(event) {
      $(humanMsg.logID).down('ul').toggle('blind');
    });
  },

  displayMsg: function(msg, msgClass) {

    if (msg === '') {
      return;
    }

    clearTimeout(humanMsg.t2);

    // Inject message
    var msgElement = $(humanMsg.msgID);
    var logElement = $(humanMsg.logID);
    msgElement.down('p').update(msg);
    logElement.down('ul').insert({ top: '<li>'+msg+'</li>' });

    if (msgClass) {
      msgElement.toggleClassName(msgClass);
    }

    msgElement.appear({ duration: 0.2 });
    logElement.down('p').show().morph('bottom:40px;',
      { duration: 0.2,
        afterFinishInternal: function(effect) {
          effect.element.morph('bottom:0px;', {
                               duration: 0.3,
                               transition: Effect.Transitions.spring
          });
      }
    });

    humanMsg.t1 = setTimeout("humanMsg.bindEvents()", 700)
    humanMsg.t2 = setTimeout("humanMsg.removeMsg()", 5000)
  },

  // Remove message if mouse is moved or key is pressed
  bindEvents: function() {
    document.observe('mousemove', humanMsg.removeMsg)
            .observe('click', humanMsg.removeMsg)
            .observe('keypress', humanMsg.removeMsg);
  },

  // Unbind mouse & keyboard
  removeMsg: function() {
    document.stopObserving('mousemove', humanMsg.removeMsg)
            .stopObserving('click', humanMsg.removeMsg)
            .stopObserving('keypress', humanMsg.removeMsg);

    $(humanMsg.msgID).fade({ duration: 0.5 });
  }
};

document.observe('dom:loaded', function() { humanMsg.setup(); });
