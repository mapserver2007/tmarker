/**
 * tmarker Firefox Addon - tmarker.js
 * url: http://tmarker.summer-lights.jp
 * version: 0.0.2
 * Copyright (c) 2010 Ryuichi TANAKA.
 */

var TmarkerUtil = {};

TmarkerUtil.bind = function(str, params) {
  for (var i = 0; i < params.length; i++) {
    str = str.replace("%s", params[i]);
  }
  return str;
};

TmarkerUtil.createElement = function(elem) {
  return document.createElementNS('http://www.w3.org/1999/xhtml', 'xhtml:' + elem);
};

TmarkerUtil.adoptNode = function(parent, elem) {
  var doc = gBrowser.contentDocument;
  var browser_version = Cc["@mozilla.org/xre/app-info;1"].getService(Ci.nsIXULAppInfo).version.substr(0, 1);
  if (parent) {
    parent.appendChild((browser_version == '3') ? doc.adoptNode(elem) : elem);
  }
};

TmarkerUtil.setPref = function(prefName, value){
  var PREF = Components.classes['@mozilla.org/preferences-service;1']
                                .getService(Components.interfaces.nsIPrefService).getBranch("");
  switch(typeof value){
  case 'string':
    var nsISupportsString = Components.interfaces.nsISupportsString;
    var string = Components.classes['@mozilla.org/supports-string;1']
                                    .createInstance(nsISupportsString);
    string.data = value;
    PREF.setComplexValue(prefName, nsISupportsString, string);
    break;
  case 'number':
    PREF.setIntPref(prefName, parseInt(value));
    break;
  default:
    PREF.setBoolPref(prefName, value);
    break;
  }
};

TmarkerUtil.getPref = function(prefName){
  var PREF = Components.classes['@mozilla.org/preferences-service;1']
                                .getService(Components.interfaces.nsIPrefService).getBranch("");
  var type = PREF.getPrefType(prefName);
  switch(type){
  case PREF.PREF_STRING:
    var nsISupportsString = Components.interfaces.nsISupportsString;
    return PREF.getComplexValue(prefName, nsISupportsString).data;
    break;
  case PREF.PREF_INT:
    return PREF.getIntPref(prefName);
    break;
  case PREF.PREF_BOOL:
    return PREF.getBoolPref(prefName);
    break;
  default:
    return;
    break;
  }
};

var Tmarker = {
  // application version
  APP_VERSION: '0.0.3',

  // application name
  APP_NAME: 'tmarker',

  // settings
  include: ['http://www.amazon.co.jp', 'http://amazon.co.jp'],
  skinPath: 'chrome://tmarker/skin/',
  loading_frame: {width: 200, height: 100}
};

Tmarker.bundle = function(key) {
  return document.getElementById("tmarker-bundle").getString(key);
};

Tmarker.init = function() {
  var self = this;
  this.status = TmarkerUtil.getPref('extensions.tmarker.status');

  window.addEventListener('load', function() {
    self.switchStatus();

    gBrowser.addEventListener('DOMContentLoaded', function(e) {
      if (gBrowser.selectedTab.linkedBrowser.contentDocument == e.originalTarget) {
        if (self.status && self.isTmarkerable()) {
          self.processing = false;
          self.addWishButton();
        }
      }
    }, false);

    gBrowser.addEventListener('resize', function(e) {
      if (self.status && self.isTmarkerable()) {
        self.loadingResize();
      }
    }, false);
  }, false);
};

Tmarker.onSwitchStatus = function(e) {
  if (e.button !== 0) return;
  this.status = !this.status;
  TmarkerUtil.setPref('extensions.tmarker.status', this.status);
  this.switchStatus();
};

Tmarker.switchStatus = function() {
  var value = this.status ? 'tmarkerPanelImageOn' : 'tmarkerPanelImageOff';
  document.getElementById('tmarkerPanel').setAttribute('class', value);
};

Tmarker.showConfig = function() {
  this.execConfigManager();
};

Tmarker.toMypage = function() {
  gBrowser.selectedTab = gBrowser.addTab(this.bundle("TMARKER_URL"));
};

Tmarker.execConfigManager = function() {
  window.openDialog('chrome://tmarker/content/config.xul', '', 'chrome,titlebar,toolbar,centerscreen,modal');
};

Tmarker.addWishButton = function() {
  var elem = this.xpath("//div[@class='GFTButtonCondo']");
  if (elem.snapshotLength > 0) {
    var style = ['margin: 5px 0;', 'cursor: pointer;'].join(' ');
    var wish_button = TmarkerUtil.createElement("img");
    wish_button.setAttribute("style", style);
    wish_button.setAttribute("src", this.skinPath + "button-wish.gif");
    wish_button.addEventListener("click", this.send, false);
    elem.snapshotItem(0).parentNode.appendChild(wish_button);
  }
};

Tmarker.getApikey = function() {
  return TmarkerUtil.getPref('extensions.tmarker.apikey');
};

Tmarker.getAsin = function() {
  var elems = this.xpath("/html/body/div[2]/table/tbody/tr/td/div/ul/li");
  for (var i = 0; i < elems.snapshotLength; i++) {
    var asin = elems.snapshotItem(i).innerHTML.replace(/<b>(.*?)<\/b>/, "");
    if (asin.match(/(B[A-Z0-9]{9})/)){
      return RegExp.$1;
    }
    else if(asin.match(/(\d{3}-\d{10})/)) {
      return RegExp.$1.replace(/-/, '');
    }
  }
};

Tmarker.xpath = function(query) {
  return window.content.document.evaluate(query, window.content.document, null,
      XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
};

Tmarker.send = function(e) {
  var self = Tmarker;
  if (!self.processing) {
    self.loading();
    var params = {url: TmarkerUtil.bind(self.bundle("WISH_REGISTER_URL"),
        [self.getApikey(), self.getAsin()])};
    self.xhr(params);
  }
  else {
    alert(self.bundle("WAITING_MESSAGE"));
  }
};

Tmarker.xhr = function(params) {
  var self = this;
  var req = new XMLHttpRequest();
  req.open("GET", params.url);
  req.setRequestHeader("Content-Type", "text/html; charset=UTF-8");
  req.setRequestHeader("User-Agent", this.APP_NAME + '/' + this.APP_VERSION);
  req.onreadystatechange = function() {
    if (req.readyState == 4 && req.status == 200) {
      eval("response = " + req.responseText);
      self.xhrResult(response);
    }
  };
  req.send();
};

Tmarker.xhrResult = function(json) {
  var self = this;
  this.loading();
  json.result ? (function(id) {
    window.content.location.href = TmarkerUtil.bind(self.bundle("MYPAGE_WISH_URL"), [id]);
  })(json.user_id) : alert(this.bundle("FAILURE_MESSAGE"));
};

Tmarker.loading = function() {
  var frame = window.content.document.getElementById("processing");
  if (frame === null) {
    this.processing = true;
    this.createLoadingFrame();
  }
  else {
    this.processing = false;
    frame.parentNode.removeChild(frame);
  }
};

Tmarker.loadingResize = function() {
  var frame = window.content.document.getElementById("processing");
  if (frame !== null) {
    frame.parentNode.removeChild(frame);
    this.createLoadingFrame();
  }
};

Tmarker.createLoadingFrame = function() {
  var _window = window.getBrowser().contentWindow;
  var style = [
               'width: '  + this.loading_frame.width + 'px;',
               'height: ' + this.loading_frame.height + 'px;',
               'left: '   + (_window.innerWidth - this.loading_frame.width) / 2 + 'px;',
               'top: '    + (_window.innerHeight - this.loading_frame.height) / 2 + 'px;',
               'position: absolute;',
               'border: 1px solid #333333;',
               'background: url(' + this.skinPath + 'ajax-loader.gif) no-repeat scroll center center;',
               'text-align: center;',
               'opacity: 0.7;',
               'background-color: #FFFFFF;'
               ].join(" ");

  var frame = TmarkerUtil.createElement("div");
  frame.setAttribute('id', 'processing');
  frame.setAttribute("style", style);
  frame.appendChild(document.createTextNode(this.bundle("WAITING_MESSAGE")));
  TmarkerUtil.adoptNode(window.content.document.body, frame);
};

Tmarker.isTmarkerable = function() {
  for (var i = 0; i < this.include.length; i++) {
    var re = new RegExp("^" + this.include[i] + ".*");
    if (window.content.document.URL.match(re)) return true;
  }
  return false;
};

if (typeof window.getBrowser == 'function') {
  Tmarker.init();
}