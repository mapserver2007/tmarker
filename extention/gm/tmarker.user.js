// ==UserScript==
// @author         Ryuichi TANAKA
// @name           tmarker
// @namespace      tmarker.summer-lights.jp
// @include        http://www.amazon.co.jp/*
// @include        http://amazon.co.jp/*
// @description    Add wishlist script for tmarker
// @version        0.0.3
// ==/UserScript==

(function(){
  var WISH_BUTTON = "http://tmarker.summer-lights.jp/images/button-wish.gif";
  var WISH_URL = "http://i.tmarker.summer-lights.jp/wish/%s/%s";
  var HOME_URL = "http://tmarker.summer-lights.jp/my/%s/wish";
  var VALUE_KEY = "apikey";
  var LOADING_FRAME_WIDTH = 200;
  var LOADING_FRAME_HEIGHT = 100;

  var PROMPT_MESSAGE = "API\u30ad\u30fc\u3092\u5165\u529b\u3057\u3066\u4e0b\u3055\u3044\u3002";
  var FAILURE_MESSAGE = "\u8cb7\u3044\u305f\u3044\u3082\u306e\u30ea\u30b9\u30c8\u306b\u767b\u9332\u3067\u304d\u307e\u305b\u3093\u3067\u3057\u305f\u3002";
  var WAITING_MESSAGE = "\u51e6\u7406\u4e2d\u3067\u3059\u3002\u304a\u5f85\u3061\u304f\u3060\u3055\u3044\u3002";

  var STYLE = <><![CDATA[
    img.add_wish {
      margin: 5px 0;
      cursor: pointer;
    }
    div.loading {
      position: absolute;
      border: 1px solid #333333;
      background: url(http://tmarker.summer-lights.jp/images/ajax-loader.gif) no-repeat scroll center center;
      text-align: center;
      opacity: 0.7;
      background-color: #FFFFFF;
    }
  ]]></>
  GM_addStyle(STYLE);

  function init() {
    if (GM_getValue(VALUE_KEY) === undefined) set_apikey();
  }

  function exec() {
    init();
    if (get_apikey() !== "" && get_asin() !== undefined) add_wish_button();
    window.addEventListener('resize', function() {
      loading_resize();
    }, false);
  }

  function bind(str, params) {
    for (var i = 0; i < params.length; i++) {
      str = str.replace("%s", params[i]);
    }
    return str;
  }

  function xpath(query) {
    return document.evaluate(query, document, null,
        XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
  }

  function add_wish_button() {
    var elem = xpath("//div[@class='GFTButtonCondo']");
    if (elem.snapshotLength > 0) {
      var wish_button = document.createElement("img");
      wish_button.setAttribute("class", "add_wish");
      wish_button.setAttribute("src", WISH_BUTTON);
      wish_button.addEventListener("click", xhr, false);
      elem.snapshotItem(0).parentNode.appendChild(wish_button);
    }
  }

  function get_asin() {
    var elems = xpath("/html/body/div[2]/table/tbody/tr/td/div/ul/li");
    for (var i = 0; i < elems.snapshotLength; i++) {
      var asin = elems.snapshotItem(i).innerHTML.replace(/<b>(.*?)<\/b>/, "");
      if (asin.match(/(B[A-Z0-9]{9})/)){
        return RegExp.$1;
      }
      else if(asin.match(/(\d{3}-\d{10})/)) {
        return RegExp.$1.replace(/-/, '');
      }
    }
  }

  function get_apikey() {
    return GM_getValue(VALUE_KEY);
  }

  function set_apikey() {
    var prompt = window.prompt(PROMPT_MESSAGE, "");
    GM_setValue(VALUE_KEY, prompt);
  }

  var processing = false;

  function xhr(e) {
    if (!processing) {
      loading();
      GM_xmlhttpRequest({
        method: "get",
        url: bind(WISH_URL, [get_apikey(), get_asin()]),
        onload: function(res) {
          eval("json = " + res.responseText);
          json.result ? success(json.user_id) : failure();
        },
        onerror: function() {
          failure();
        }
      });
    }
    else {
      alert(WAITING_MESSAGE);
    }
  }

  function success(id) {
    loading();
    location.href = bind(HOME_URL, [id]);
  }

  function failure() {
    loading();
    alert(FAILURE_MESSAGE);
  }

  function create_loading_frame() {
    var style = [
                 'width: '  + LOADING_FRAME_WIDTH + 'px;',
                 'height: ' + LOADING_FRAME_HEIGHT + 'px;',
                 'left: '   + (window.innerWidth - LOADING_FRAME_WIDTH) / 2 + 'px;',
                 'top: '    + (window.innerHeight - LOADING_FRAME_HEIGHT) / 2 + 'px;'
                 ].join(" ");

    var frame = document.createElement("div");
    frame.setAttribute("id", "processing")
    frame.setAttribute("class", "loading");
    frame.setAttribute("style", style);
    frame.innerHTML = WAITING_MESSAGE;
    window.document.body.appendChild(frame);
  }

  function loading() {
    var frame = document.getElementById("processing");
    if (frame === null) {
      processing = true;
      create_loading_frame();
    }
    else {
      processing = false;
      frame.parentNode.removeChild(frame);
    }
  }

  function loading_resize() {
    var frame = window.content.document.getElementById("processing");
    if (frame !== null) {
      frame.parentNode.removeChild(frame);
      create_loading_frame();
    }
  }

  exec();
})();